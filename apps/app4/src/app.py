def handler(event, context):
    ''' Lambda App 3 '''
    print("hello from app4!")

    expected_response = {
        "statusCode": 201,
        "headers": {
            "Content-Type": "application/json",
            "My-Custom-Header": "APP4"
        },
        "body": "{ \"message\": \"This is app4, after editing.\" }",

        "isBase64Encoded": False
    }

    print("Hello from APP4")


    return expected_response 