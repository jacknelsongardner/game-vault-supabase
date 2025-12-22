create or replace function get_closest_friends(user_id uuid, top_n int, degrees int default 1)
returns table(friend_id uuid, similarity float)
language plpgsql
as $$
declare
    has_friends boolean;
begin
    -- Check if the user has any direct friends
    select exists (
        select 1 from friend 
        where friendOne = user_id or friendTwo = user_id
    ) into has_friends;

    if not has_friends then
        -- No friends: compare to all other users
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
        -- User has friends: traverse friends up to `degrees`
        return query
        with recursive friend_network(level, fid) as (
            select 1, f.friendTwo
            from friend f
            where f.friendOne = user_id
            union
            select 1, f.friendOne
            from friend f
            where f.friendTwo = user_id
            union all
            select fn.level + 1,
                   case when f.friendOne = fn.fid then f.friendTwo else f.friendOne end
            from friend_network fn
            join friend f on f.friendOne = fn.fid or f.friendTwo = fn.fid
            where fn.level < degrees
        ),
        network_vectors as (
            select distinct fn.fid as friend_id, pi.game_vector
            from friend_network fn
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
