import boto3


def handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    counter_table = dynamodb.Table('viewcounter')

    counter_table.update_item(
        Key={'counter_name': 'view_counter'},
        UpdateExpression="ADD counter_value :increment",
        ExpressionAttributeValues={':increment': 1}
    )
    item = counter_table.get_item(Key={'counter_name': 'view_counter'})
    return unicode(item['Item']['counter_value'])
