-- Add better error handling to the user creation triggers
-- This will help debug any remaining issues

-- Improved handle_new_user function with error handling
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a new profile for the user
  BEGIN
    INSERT INTO public.profile (auth_id)
    VALUES (NEW.id);
  EXCEPTION WHEN OTHERS THEN
    -- Log the error but don't fail the trigger
    RAISE WARNING 'Failed to create profile for user %: % %', NEW.id, SQLERRM, SQLSTATE;
    -- Re-raise to fail the user creation if profile creation fails
    RAISE;
  END;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Improved create_profile_vectors function with error handling
create or replace function create_profile_vectors()
returns trigger
language plpgsql
as $$
declare
  vector_size int;
begin
  BEGIN
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
    else
      -- Log that we're skipping vector creation due to empty genre_enum
      RAISE NOTICE 'Skipping profile_interests creation for user % because genre_enum is empty', new.id;
    end if;
  EXCEPTION WHEN OTHERS THEN
    -- Log the error but don't fail the trigger
    RAISE WARNING 'Failed to create profile_interests for user %: % %', new.id, SQLERRM, SQLSTATE;
    -- Don't re-raise - we don't want to block user creation if vector creation fails
  END;

  return new;
end;
$$;
