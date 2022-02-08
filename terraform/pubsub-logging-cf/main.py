import os
import logging
import base64
from pythonjsonlogger import jsonlogger

def process_pubsub(event, context):
  logger = setup_logging()
  logger.debug("Pub/Sub logging function running")
  if  not 'data' in event:
    logger.error("There is no data in the event dict.")
  else:
    data = base64.b64decode(event['data']).decode('raw_unicode_escape')
    logger.info("Received Pub/Sub message!", extra={
      'event_id:': context.event_id,
      'data': data,
      'attributes': event['attributes']
    })

def setup_logging():
    logger = logging.getLogger('logging_cf')
    if os.getenv('LOG_LEVEL'):
        logger.setLevel(int(os.getenv('LOG_LEVEL')))
    else:
        logger.setLevel(logging.INFO)
    json_handler = logging.StreamHandler()
    formatter = jsonlogger.JsonFormatter()
    json_handler.setFormatter(formatter)
    logger.addHandler(json_handler)
    return logger
