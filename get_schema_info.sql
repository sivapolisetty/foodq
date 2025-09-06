-- Get schema information for deals and businesses tables
CREATE OR REPLACE FUNCTION get_schema_info()
RETURNS TABLE (
  table_name TEXT,
  column_name TEXT,
  data_type TEXT,
  character_maximum_length INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.table_name::TEXT,
    c.column_name::TEXT,
    c.data_type::TEXT,
    c.character_maximum_length
  FROM information_schema.columns c
  WHERE c.table_name IN ('deals', 'businesses')
    AND c.table_schema = 'public'
  ORDER BY c.table_name, c.ordinal_position;
END;
$$;

GRANT EXECUTE ON FUNCTION get_schema_info TO authenticated;
GRANT EXECUTE ON FUNCTION get_schema_info TO service_role;