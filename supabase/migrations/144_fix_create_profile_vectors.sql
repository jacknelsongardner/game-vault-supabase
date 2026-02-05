-- Update the create_profile_vectors function to handle empty genre_enum table
create or replace function create_profile_vectors()
returns trigger
language plpgsql
as $$
declare
  vector_size int;
begin
  -- Get the count of genres
  select count(*) into vector_size from genre_enum;

  -- Only insert if we have genres (vector_size > 0)
  -- This prevents issues with 0-dimensional vectors
  if vector_size > 0 then
    insert into profile_interests (auth_id, game_vector, weights)
    values (
      new.id,
      vector_zero(vector_size),
      vector_one(vector_size)
    );
  end if;

  return new;
end;
$$;
