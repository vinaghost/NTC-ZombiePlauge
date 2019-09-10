#if defined _json_included
	#endinput
#endif

#define _json_included

#include < amxmodx >

#define JSON_KEY_SIZE   512
#define JSON_STR_SIZE   512

//#define JSON_DEBUG

#if defined JSON_DEBUG
	#define JSON_VAR new
	#define JSON_FUNC
#else
	#define JSON_VAR stock
	#define JSON_FUNC stock
#endif

JSON_VAR __json_key[ JSON_KEY_SIZE ];
JSON_VAR __json_key2[ JSON_KEY_SIZE ];
JSON_VAR __json_string[ JSON_STR_SIZE ];

enum JSON
{
	JSON_INVALID = 0,
	
	JSON_Cell,
	JSON_Float,
	JSON_String,
	JSON_Object
};

JSON_FUNC JSON:json_create(bool:is_array=false)
{
	new Trie:object = TrieCreate( );
	
	if( object == Invalid_Trie )
	{
		return JSON_INVALID;
	}
	
	new Trie:data = TrieCreate( );
	new Array:keys = ArrayCreate( JSON_KEY_SIZE );
	
	TrieSetCell( object, "data", data );
	TrieSetCell( object, "keys", keys );
	
	if( is_array )
	{
		TrieSetCell( object, "is_array", true );
	}
	
	return JSON:object;
}

JSON_FUNC JSON:json_from_array(const any:array[], size, JSON:types[]={JSON_INVALID}, JSON:force_type=JSON_INVALID)
{
	new JSON:json = json_create( .is_array = true );
	
	if( json == JSON_INVALID )
	{
		return JSON_INVALID;
	}
	
	new key[ 12 ];
	
	for( new i = 0; i < size; i++ )
	{
		num_to_str( i, key, charsmax( key ) );
		
		json_set_cell( json, key, array[ i ], ( force_type ? force_type : types[ i ] ) );
	}
	
	return json;
}

JSON_FUNC JSON:json_from_array2(Array:array, size=-1, {Array,JSON}:types, bool:force_type=false)
{
	if( array == Invalid_Array )
	{
		return JSON_INVALID;
	}
	
	if( size < 0 )
	{
		size = ArraySize( array );
	}
	
	if( !size )
	{
		return JSON_INVALID;
	}
	
	new JSON:json = json_create( .is_array = true );
	
	if( json == JSON_INVALID )
	{
		return JSON_INVALID;
	}
	
	new key[ 12 ];
	
	for( new i = 0; i < size; i++ )
	{
		num_to_str( i, key, charsmax( key ) );
		
		json_set_cell( json, key, ArrayGetCell( array, i ), JSON:( force_type ? types : ArrayGetCell( types, i ) ) );
	}
	
	return json;
}

JSON_FUNC bool:json_set_cell(JSON:object, const key[], any:value, JSON:type=JSON_Cell)
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data, Array:keys;
	
	TrieGetCell( Trie:object, "data", data );
	TrieGetCell( Trie:object, "keys", keys );
	
	if( !__json_delete( data, key ) )
	{
		ArrayPushString( keys, key );
	}
	
	new Trie:info = TrieCreate( );
	
	TrieSetCell( info, "type", type );
	TrieSetCell( info, "value", value );
	
	TrieSetCell( data, key, info );
	
	return true;
}

JSON_FUNC bool:json_set_array(JSON:object, const key[], const any:array[], size, JSON:types[]={JSON_INVALID}, JSON:force_type=JSON_INVALID)
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new JSON:child = json_from_array( array, size, types, force_type );
	
	return ( child == JSON_INVALID ) ? false : json_set_cell( object, key, child, JSON_Object );
}

JSON_FUNC bool:json_set_array2(JSON:object, const key[], Array:array, size=-1, {Array,JSON}:types, bool:force_type=false)
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new JSON:child = json_from_array2( array, size, types, force_type );
	
	return ( child == JSON_INVALID ) ? false : json_set_cell( object, key, child, JSON_Object );
}

JSON_FUNC bool:json_set_string(JSON:object, const key[], const string[])
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data, Array:keys;
	
	TrieGetCell( Trie:object, "data", data );
	TrieGetCell( Trie:object, "keys", keys );
	
	if( !__json_delete( data, key ) )
	{
		ArrayPushString( keys, key );
	}
	
	new Trie:info = TrieCreate( );
	
	TrieSetCell( info, "type", JSON_String );
	TrieSetString( info, "value", string );
	
	TrieSetCell( data, key, info );
	
	return true;
}

JSON_FUNC bool:json_get_cell(JSON:object, const key[], &any:value, &JSON:type=JSON_Cell)
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data;
	TrieGetCell( Trie:object, "data", data );
	
	new Trie:info;
	
	if( !TrieGetCell( data, key, info ) )
	{
		return false;
	}
	
	TrieGetCell( info, "type", type );
	
	if( type != JSON_Cell && type != JSON_Float && type != JSON_Object )
	{
		return false;
	}
	
	TrieGetCell( info, "value", value );
	
	return true;
}

JSON_FUNC bool:json_get_array(JSON:object, const key[], any:output[], size, JSON:types[])
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data;
	TrieGetCell( Trie:object, "data", data );
	
	new Trie:info;
	
	if( !TrieGetCell( data, key, info ) )
	{
		return false;
	}
	
	new JSON:type;
	TrieGetCell( info, "type", type );
	
	if( type != JSON_Object )
	{
		return false;
	}
	
	new JSON:array;
	TrieGetCell( data, "value", array );
	
	new num[ 12 ];
	new index;
	
	while( index < size )
	{
		num_to_str( index, num, charsmax( num ) );
		
		if( !json_get_cell( array, num, output[ index ], types[ index ] ) )
		{
			break;
		}
		
		index++;
	}
	
	return ( index > 0 );
}

JSON_FUNC bool:json_get_array2(JSON:object, const key[], &Array:output, &size=0, &Array:types)
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data;
	TrieGetCell( Trie:object, "data", data );
	
	new Trie:info;
	
	if( !TrieGetCell( data, key, info ) )
	{
		return false;
	}
	
	new JSON:type;
	TrieGetCell( info, "type", type );
	
	if( type != JSON_Object )
	{
		return false;
	}
	
	new JSON:array;
	TrieGetCell( data, "value", array );
	
	new num[ 12 ];
	num_to_str( 0, num, charsmax( num ) );
	
	new index, value;
	
	while( index < size )
	{
		num_to_str( index, num, charsmax( num ) );
		
		if( !json_get_cell( array, num, value, type ) )
		{
			break;
		}
		
		ArrayPushCell( output, value );
		ArrayPushCell( types, type );
		
		index++;
	}
	
	return ( index > 0 );
}

JSON_FUNC bool:json_get_string(JSON:object, const key[], output[], len)
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data;
	TrieGetCell( Trie:object, "data", data );
	
	new Trie:info;
	
	if( !TrieGetCell( data, key, info ) )
	{
		return false;
	}
	
	new JSON:type;
	TrieGetCell( info, "type", type );
	
	if( type != JSON_String )
	{
		return false;
	}
	
	TrieGetString( info, "value", output, len );
	
	return true;
}

JSON_FUNC JSON:json_get_type(JSON:object, const key[])
{
	if( object == JSON_INVALID )
	{
		return JSON_INVALID;
	}
	
	new Trie:data;
	TrieGetCell( Trie:object, "data", data );
	
	new Trie:info;
	
	if( !TrieGetCell( data, key, info ) )
	{
		return JSON_INVALID;
	}
	
	new JSON:type;
	TrieGetCell( info, "type", type );
	
	return type;
}

JSON_FUNC bool:json_delete(JSON:object, const key[])
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data, Array:keys;
	
	TrieGetCell( Trie:object, "data", data );
	TrieGetCell( Trie:object, "keys", keys );
	
	new size = ArraySize( keys );
	
	return __json_delete( data, key, keys, size );
}

JSON_FUNC bool:__json_delete(Trie:data, const key[], Array:keys=Invalid_Array, &size=0)
{
	new Trie:info;
	
	if( TrieGetCell( data, key, info ) )
	{
		TrieDeleteKey( data, key );
		
		if( keys != Invalid_Array && size > 0 )
		{
			for( new i = 0; i < size; i++ )
			{
				ArrayGetString( keys, i, __json_key2, charsmax( __json_key2 ) );
				
				if( equal( __json_key2, key ) )
				{
					ArrayDeleteItem( keys, i-- );
					size--;
				}
			}
		}
		
		new JSON:type;
		TrieGetCell( info, "type", type );
		
		if( type == JSON_Object )
		{
			new JSON:object;
			TrieGetCell( info, "value", object );
			
			json_destroy( object );
		}
		
		TrieDestroy( info );
		
		return true;
	}
	
	return false;
}

JSON_FUNC JSON:json_decode(const string[], &pos=0, len=0)
{
	if( !len && !( len = strlen( string ) ) )
	{
		return JSON_INVALID;
	}
	
	while( pos < len && isspace( string[ pos ] ) )
	{
		pos++;
	}
	
	while( len > 0 && isspace( string[ len - 1 ] ) )
	{
		len--;
	}
	
	if( !len || pos >= len )
	{
		return JSON_INVALID;
	}
	
	new JSON:json = JSON_INVALID;
	
	switch( string[ pos ] )
	{
		case '{':
		{
			json = json_create( );
			
			new key_start, key_len;
			new bool:escaped;
			new JSON:child;
			new Array:array;
			new Array:types;
			new string_start;
			new string_len;
			
			while( ++pos < len && isspace( string[ pos ] ) ) { }
			
			while( json )
			{	
				if( pos >= len || string[ pos ] != '"' )
				{
					json_destroy( json );
					return JSON_INVALID;
				}
				
				key_start = pos + 1;
				escaped = false;
				
				while( ++pos <= len )
				{
					if( pos == len )
					{
						json_destroy( json );
						return JSON_INVALID;
					}
					
					if( escaped )
					{
						escaped = false;
					}
					else if( string[ pos ] == '\' )
					{
						escaped = true;
					}
					else if( string[ pos ] == '"' )
					{
						break;
					}
				}
				
				key_len = pos - key_start;
				
				if( !key_len )
				{
					json_destroy( json );
					return JSON_INVALID;
				}
				
				while( ++pos < len && isspace( string[ pos ] ) ) { }
				
				if( string[ pos ] != ':' )
				{
					json_destroy( json );
					return JSON_INVALID;
				}
				
				while( ++pos < len && isspace( string[ pos ] ) ) { }
				
				switch( string[ pos ] )
				{
					case '{':
					{
						// Read JSON
						child = json_decode( string, pos, len );
						
						if( child == JSON_INVALID )
						{
							json_destroy( json );
							return JSON_INVALID;
						}
						
						copy( __json_key, min( charsmax( __json_key ), key_len ), string[ key_start ] );
						
						json_set_cell( json, __json_key, child, JSON_Object );
					}
					case '[':
					{
						// Read array
						array = __json_read_array( string, len, pos, string_len, types );
						
						if( array == Invalid_Array )
						{
							json_destroy( json );
							return JSON_INVALID;
						}
						
						copy( __json_key, min( charsmax( __json_key ), key_len ), string[ key_start ] );
						
						json_set_array2( json, __json_key, array, string_len, types, .force_type = false );
						
						ArrayDestroy( array );
						ArrayDestroy( types );
					}
					case '"':
					{
						// Read string
						escaped = false;
						
						string_len = 0;
						__json_string[ 0 ] = EOS;
						
						while( ++pos <= len )
						{
							if( pos == len )
							{
								json_destroy( json );
								return JSON_INVALID;
							}
							
							if( escaped )
							{
								escaped = false;
								
								if( string_len < charsmax( __json_string ) )
								{
									__json_string[ string_len++ ] = string[ pos ];
								}
							}
							else if( string[ pos ] == '\' )
							{
								escaped = true;
							}
							else if( string[ pos ] == '"' )
							{
								pos++;
								break;
							}
							else
							{
								
								if( string_len < charsmax( __json_string ) )
								{
									__json_string[ string_len++ ] = string[ pos ];
								}
							}
							
							pos++;
						}
						
						if( !string_len )
						{
							json_destroy( json );
							return JSON_INVALID;
						}
						
						copy( __json_key, min( charsmax( __json_key ), key_len ), string[ key_start ] );
						
						json_set_string( json, __json_key, __json_string );
					}
					default:
					{
						// Read true/false, integer, or float
						string_start = pos;
						
						while( ++pos < len && !isspace( string[ pos ] ) ) { }
						
						string_len = pos - string_start;
						
						copy( __json_string, min( charsmax( __json_string ), string_len ), string[ string_start ] );
						
						if( equali( __json_string, "true" ) || equali( __json_string, "false" ) )
						{
							copy( __json_key, min( charsmax( __json_key ), key_len ), string[ key_start ] );
							
							json_set_cell( json, __json_key, ( __json_string[ 0 ] == 't' || __json_string[ 0 ] == 'T' ) );
						}
						else if( is_str_num( __json_string ) )
						{
							copy( __json_key, min( charsmax( __json_key ), key_len ), string[ key_start ] );
							
							json_set_cell( json, __json_key, str_to_num( __json_string ) );
						}
						else
						{
							string_len = contain( __json_string, "." );
							
							if( string_len <= 0 || !is_str_num( __json_string[ string_len + 1 ] ) )
							{
								json_destroy( json );
								return JSON_INVALID;
							}
							
							__json_string[ string_len ] = EOS;
							
							string_start = _:!!( __json_string[ 0 ] == '-' );
							
							if( !is_str_num( __json_string[ string_start ] ) )
							{
								json_destroy( json );
								return JSON_INVALID;
							}
							
							__json_string[ string_len ] = '.';
							
							copy( __json_key, min( charsmax( __json_key ), key_len ), string[ key_start ] );
							
							json_set_cell( json, __json_key, str_to_float( __json_string ), JSON_Float );
						}
					}
				}
				
				while( pos < len && isspace( string[ pos ] ) )
				{
					pos++;
				}
				
				if( string[ pos ] == '}' )
				{
					pos++;
					break;
				}
				else if( string[ pos ] != ',' )
				{
					json_destroy( json );
					return JSON_INVALID;
				}
				
				while( ++pos < len && isspace( string[ pos ] ) ) { }
			}
		}
		case '[':
		{
			// Read array
			new size;
			new Array:types;
			
			new Array:array = __json_read_array( string, len, pos, size, types );
			
			if( array == Invalid_Array )
			{
				return JSON_INVALID;
			}
			
			json = json_from_array2( array, size, types );
			
			ArrayDestroy( array );
			ArrayDestroy( types );
		}
	}
	
	return json;
}

JSON_FUNC Array:__json_read_array(const string[], len, &pos, &size, &Array:types)
{
	new Array:output = ArrayCreate( JSON_STR_SIZE );
	size = 0;
	types = ArrayCreate( );
	
	new bool:failed;
	
	new JSON:child;
	new Array:array;
	new array_size;
	new Array:array_types;
	new bool:escaped;
	new string_start;
	new string_len;
	
	while( ++pos <= len )
	{
		while( pos < len && isspace( string[ pos ] ) )
		{
			pos++;
		}
		
		if( pos == len )
		{
			failed = true;
			goto check_fail;
		}
		
		switch( string[ pos ] )
		{
			case ']':
			{
				pos++;
				break;
			}
			case '{':
			{
				child = json_decode( string, pos, len );
				
				if( child == JSON_INVALID )
				{
					failed = true;
					goto check_fail;
				}
				
				ArrayPushCell( output, child );
				ArrayPushCell( types, JSON_Object );
				size++;
			}
			case '[':
			{
				array = __json_read_array( string, len, pos, array_size, array_types );
				
				if( array == Invalid_Array )
				{
					failed = true;
					goto check_fail;
				}
				
				ArrayPushCell( output, json_from_array2( array, array_size, array_types ) );
				ArrayPushCell( types, JSON_Object );
				size++;
				
				ArrayDestroy( array );
				ArrayDestroy( array_types );
			}
			case '"':
			{
				// Read string
				escaped = false;
				
				string_len = 0;
				__json_string[ 0 ] = EOS;
				
				while( ++pos <= len )
				{
					if( pos == len )
					{
						failed = true;
						goto check_fail;
					}
					
					if( escaped )
					{
						escaped = false;
						
						if( string_len < charsmax( __json_string ) )
						{
							__json_string[ string_len++ ] = string[ pos ];
						}
					}
					else if( string[ pos ] == '\' )
					{
						escaped = true;
					}
					else if( string[ pos ] == '"' )
					{
						pos++;
						break;
					}
					else
					{
						
						if( string_len < charsmax( __json_string ) )
						{
							__json_string[ string_len++ ] = string[ pos ];
						}
					}
					
					pos++;
				}
				
				if( !string_len )
				{
					failed = true;
					goto check_fail;
				}
				
				ArrayPushString( output, __json_string );
				ArrayPushCell( types, JSON_String );
				size++;
			}
			default:
			{
				// Read true/false, integer, or float
				string_start = pos;
				
				while( ++pos < len && !isspace( string[ pos ] ) ) { }
				
				string_len = pos - string_start;
				
				copy( __json_string, min( charsmax( __json_string ), string_len ), string[ string_start ] );
				
				if( equali( __json_string, "true" ) || equali( __json_string, "false" ) )
				{
					ArrayPushCell( output, ( __json_string[ 0 ] == 't' || __json_string[ 0 ] == 'T' ) );
					ArrayPushCell( types, JSON_Cell );
					size++;
				}
				else if( is_str_num( __json_string ) )
				{
					ArrayPushCell( output, str_to_num( __json_string ) );
					ArrayPushCell( types, JSON_Cell );
					size++;
				}
				else
				{
					string_len = contain( __json_string, "." );
					
					if( string_len <= 0 || !is_str_num( __json_string[ string_len + 1 ] ) )
					{
						failed = true;
						goto check_fail;
					}
					
					__json_string[ string_len ] = EOS;
					
					string_start = _:!!( __json_string[ 0 ] == '-' );
					
					if( !is_str_num( __json_string[ string_start ] ) )
					{
						failed = true;
						goto check_fail;
					}
					
					__json_string[ string_len ] = '.';
					
					ArrayPushCell( output, str_to_float( __json_string ) );
					ArrayPushCell( types, JSON_Float );
					size++;
				}
			}
		}
		
		while( pos < len && isspace( string[ pos ] ) )
		{
			pos++;
		}
		
		if( string[ pos ] == ']' )
		{
			pos++;
			break;
		}
		else if( string[ pos ] != ',' )
		{
			failed = true;
			goto check_fail;
		}
	}
	
	check_fail:
	
	if( failed )
	{
		while( --size >= 0 )
		{
			if( ArrayGetCell( types, size ) == JSON_Object )
			{
				child = ArrayGetCell( output, size );
				
				json_destroy( child );
			}
		}
		
		ArrayDestroy( output );
		ArrayDestroy( types );
		
		output = Invalid_Array;
	}
	
	return output;
}

JSON_FUNC json_encode(JSON:object, output[], len)
{
	if( object == JSON_INVALID )
	{
		return 0;
	}
	
	new Trie:data, Array:keys;
	
	TrieGetCell( Trie:object, "data", data );
	TrieGetCell( Trie:object, "keys", keys );
	
	new bool:is_array = TrieKeyExists( Trie:object, "is_array" );
	
	new pos = copy( output, len, is_array ? "[" : "{" );
	
	new size = ArraySize( keys );
	
	new Trie:info;
	new bool:first = true;
	new JSON:type;
	new value;
	
	for( new i = 0; i < size; i++ )
	{
		ArrayGetString( keys, i, __json_key, charsmax( __json_key ) );
		
		if( TrieGetCell( data, __json_key, info ) )
		{
			if( first )
			{
				first = false;
			}
			else
			{
				pos += copy( output[ pos ], len - pos, "," );
			}
			
			if( !is_array )
			{
				pos += copy( output[ pos ], len - pos, "^"" );
				
				pos += json_escape( __json_key, output[ pos ], len - pos );
				
				pos += copy( output[ pos ], len - pos, "^":" );
			}
			
			TrieGetCell( info, "type", type );
			
			switch( type )
			{
				case JSON_Cell:
				{
					TrieGetCell( info, "value", value );
					
					pos += formatex( output[ pos ], len - pos, "%d", value );
				}
				case JSON_Float:
				{
					TrieGetCell( info, "value", value );
					
					pos += formatex( output[ pos ], len - pos, "%f", value );
					
					// Remove insignificant digits
					while( output[ --pos ] == '0' ) { }
					
					if( output[ pos ] == '.' )
					{
						output[ pos ] = EOS;
					}
					else
					{
						
						output[ ++pos ] = EOS;
					}
				}
				case JSON_String:
				{
					TrieGetString( info, "value", __json_string, charsmax( __json_string ) );
					
					pos += copy( output[ pos ], len - pos, "^"" );
					
					pos += json_escape( __json_string, output[ pos ], len - pos );
					
					pos += copy( output[ pos ], len - pos, "^"" );
				}
				case JSON_Object:
				{
					TrieGetCell( info, "value", value );
					
					pos += json_encode( JSON:value, output[ pos ], len - pos );
				}
			}
		}
	}
	
	pos += copy( output[ pos ], len - pos, is_array ? "]" : "}" );
	
	return pos;
}

JSON_FUNC json_escape(const string[], output[], len)
{
	new pos, c, o;
	
	while( ( c = string[ pos++ ] ) > 0 )
	{
		if( o == len )
		{
			// Out of room for the rest of the string
			// Fail the escaping since we cannot give back full string
			o = 0;
			break;
		}
		
		if( c == '"' || c == '\' )
		{
			if( ( o + 2 ) > len )
			{
				// Cannot finish escaping the string, so fail the function
				o = 0;
				break;
			}
			
			output[ o++ ] = '\';
			output[ o++ ] = c;
		}
		else
		{
			output[ o++ ] = c;
		}
	}
	
	output[ o ] = EOS;
	
	return o;
}

JSON_FUNC bool:json_destroy(&JSON:object)
{
	if( object == JSON_INVALID )
	{
		return false;
	}
	
	new Trie:data, Array:keys;
	
	TrieGetCell( Trie:object, "data", data );
	TrieGetCell( Trie:object, "keys", keys );
	
	new size = ArraySize( keys );
	
	for( new i = 0; i < size; i++ )
	{
		ArrayGetString( keys, i, __json_key, charsmax( __json_key ) );
		
		__json_delete( data, __json_key );
	}
	
	TrieDestroy( data );
	ArrayDestroy( keys );
	
	TrieDestroy( Trie:object );
	
	object = JSON_INVALID;
	
	return true;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
