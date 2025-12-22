create or replace function update_profile_vector_on_game_owned()
returns trigger
language plpgsql
as $$
declare
  increment_vector vector;
begin
  select vector_from_array(
    array_agg(
      case
        when ge.genre_id is not null then 1
        else 0
      end
      order by gs.i
    )
  )
  into increment_vector
  from generate_series(0, (
    select vector_dims(game_vector) - 1
    from profile_interests
    where auth_id = new.profile_id
  )) gs(i)
  left join genre ge
    on ge.genre_id = gs.i + 1  -- genre_enum.id starts at 1
   and ge.game_id = new.game_id;

  update profile_interests
  set game_vector = game_vector + increment_vector
  where auth_id = new.profile_id;

  return new;
end;
$$;

create or replace trigger on_game_owned_update_vector
after insert on game_owned
for each row
execute function update_profile_vector_on_game_owned();
