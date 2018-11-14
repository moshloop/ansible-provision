from ansible import errors
import os.path

def is_truthy(arg):
  if arg == None:
    return False
  if type(arg) == 'string':
    arg = arg.lower()
  return arg or arg == 'true' or arg == 'yes'

class FilterModule(object):
  '''Returns true if the argument is true, "true", "True", "yes"'''
  def filters(self):
      return {
          'is_truthy' : is_truthy
      }
