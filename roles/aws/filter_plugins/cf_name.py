import re

def cf_name(name):
  return name.replace("-", "").replace("_", "")

class FilterModule(object):
     """Convert a string into a CloudFormation compatible name"""
     def filters(self):
         return {'cf_name': cf_name}
