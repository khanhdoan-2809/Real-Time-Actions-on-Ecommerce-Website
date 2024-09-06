import boto3
import json

def lambda_handler(event, context):
    if 'body' in event:
        event = json.loads(event['body'])
    else:
        event = json.loads(event['Records'][0]['body'])
        
    required_fields = ['id', 'title', 'price', 'category']
    processed_data = {field: event.get(field) for field in required_fields}
    
    processed_data_json = json.dumps(processed_data)
    
    encoded_data = processed_data_json.encode('utf-8')
    
    # create Kinesis 
    kinesis_client = boto3.client('kinesis')
    
    response = kinesis_client.put_record(
        StreamName='kinesis_stream',
        Data=encoded_data,
        PartitionKey='partition_key'
    )
    
    return {
        'statusCode': 200,
        'body': 'Processed Data sent to Kinesis stream successfully.',
        'response': response
    }