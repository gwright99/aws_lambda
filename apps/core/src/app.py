def handler(event, context):
    ''' The first function to be invoked by Lambda '''
    print("Replace me with something better!")

    expected_response = {
        "statusCode": 418,
        "headers": {
            "Content-Type": "application/json",
            "Repalce": "Me"
        },
        "body": "{ \"message\": \"REPLACE ME\" }",
        "isBase64Encoded": False
    }

    return expected_response 