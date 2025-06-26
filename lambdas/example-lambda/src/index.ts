import { Handler } from 'aws-lambda';

export const handler: Handler = async (event) => {
  console.log('Received event:', event);
  return {
    statusCode: 200,
    body: 'Event logged',
  };
};
