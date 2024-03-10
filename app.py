def handler(event, context):
    ''' The first function to be invoked by Lambda '''
    print("hello!")

    json_data = [{"Dp_Record_Id": 2, 
                  "DP_TYPE": "NSDL",
                  "DP_ID": "40877589", 
                  "CLIENT_ID": "1232", 
                  "Default_flag": "Y"}]

    return {'statusCode': 200,
            'headers': {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": 'GET, POST, PUT, DELETE, OPTIONS'
            },
            'body': json_data
        }  