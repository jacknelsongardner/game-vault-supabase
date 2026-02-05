
create extension if not exists vector;


-- Table already created in 139_profile_vectors.sql, removed duplicate
-- create table profile_interests (
--   auth_id uuid primary key references auth.users(id) on delete cascade,
--   game_vector vector,   -- vector for game genres or whatever else we want to utilize
--   weights vector        -- per-dimension weights
-- );


create or replace function create_profile_vectors()
returns trigger
language plpgsql
as $$
declare
  vector_size int;
begin
  select count(*) into vector_size from genre_enum;

  insert into profile_interests (auth_id, game_vector, weights)
  values (
    new.id,
    vector_zero(vector_size),
    vector_one(vector_size)
  );

  return new;
end;
$$;

create trigger on_user_created_vectors
after insert on auth.users
for each row
execute function create_profile_vectors();