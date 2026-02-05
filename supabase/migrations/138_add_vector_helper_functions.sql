-- Add helper functions for creating vectors filled with zeros and ones
-- These are needed by the create_profile_vectors trigger

create extension if not exists vector;

-- Function to create a vector filled with zeros
create or replace function vector_zero(size int)
returns vector
language plpgsql
immutable
as $$
declare
  result vector;
  zero_array float[];
begin
  -- Create an array of zeros with the specified size
  select array_agg(0.0::float)
  into zero_array
  from generate_series(1, size);
  
  -- Cast the array to a vector
  result := zero_array::vector;
  
  return result;
end;
$$;

-- Function to create a vector filled with ones
create or replace function vector_one(size int)
returns vector
language plpgsql
immutable
as $$
declare
  result vector;
  one_array float[];
begin
  -- Create an array of ones with the specified size
  select array_agg(1.0::float)
  into one_array
  from generate_series(1, size);
  
  -- Cast the array to a vector
  result := one_array::vector;
  
  return result;
end;
$$;
