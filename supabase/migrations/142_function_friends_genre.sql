create or replace function get_closest_friends(user_id uuid, top_n int, degrees int default 1)
returns table(friend_id uuid, similarity float)
language plpgsql
as $$
declare
    has_following boolean;
begin
    -- Check if the user follows anyone
    select exists (
        select 1 from follower
        where follower_id = user_id
    ) into has_following;

    if not has_following then
        -- No follows: compare to all other users
        return query
        select
            pi.auth_id as friend_id,
            1 - (pi_user.game_vector <=> pi.game_vector) as similarity
        from profile_interests pi
        cross join (select game_vector from profile_interests where auth_id = user_id) pi_user
        where pi.auth_id <> user_id
        order by similarity desc
        limit top_n;
    else
        -- Traverse the follow network up to `degrees` hops
        return query
        with recursive follow_network(level, fid) as (
            -- Direct follows (degree 1)
            select 1, f.following_id
            from follower f
            where f.follower_id = user_id
            union all
            -- Deeper hops: people followed by those we already found
            select fn.level + 1, f.following_id
            from follow_network fn
            join follower f on f.follower_id = fn.fid
            where fn.level < degrees
              and f.following_id <> user_id
        ),
        network_vectors as (
            select distinct fn.fid as friend_id, pi.game_vector
            from follow_network fn
            join profile_interests pi on pi.auth_id = fn.fid
        ),
        user_vector as (
            select game_vector from profile_interests where auth_id = user_id
        )
        select
            nv.friend_id,
            1 - (uv.game_vector <=> nv.game_vector) as similarity
        from network_vectors nv
        cross join user_vector uv
        order by similarity desc
        limit top_n;
    end if;
end;
$$;


create or replace trigger on_game_owned_update_vector
after insert on game_owned
for each row
execute function update_profile_vector_on_game_owned();
