def handler(event, context):
    ''' App2 logic '''
    print("Hello from App2")

    expected_response = {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json",
            "Custom-Header": "Hello_from_App2"
        },
        # "body": "{ \"message\": \"Hello from App2!\" }",
        # "cookies": [
        #     "Cookie_1=Value1; Expires=21 Oct 2021 07:48 GMT",
        #     "Cookie_2=Value2; Max-Age=78000"
        # ],
        "isBase64Encoded": False
    }

    return expected_response 