#!/usr/bin/python

#import socket
#print(socket.gethostname())
import yaml
import os
import re
import string

HOSTNAME="mesos-master-101.local-domain.com" 

dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
config_file=os.path.join(dir, 'classification' + "." + 'yaml')

def main():
  p = re.compile('([\w]*[-]*[\w]*)[-]?([\d]{3})')
  hostname = HOSTNAME
  if hostname.endswith("."):
    hostname = hostname[:-1] 
    
  m = p.match(hostname)
  hostname = m.group(1)
      
  f = open(config_file)
  dataMap = yaml.safe_load(f)

  return yaml.dump(do_nodes(hostname, dataMap))
  
def do_nodes(hostname, data):
  nodes = data["nodes"]
  result = 'xyz'
  if not nodes:
    print data["groups"]['default']["classes"]
    return
  for k in nodes:
    if hostname in k: 
      result = nodes[k]["classes"]
      if result:
        group_list = nodes[k]["groups"]
        for group in group_list:
          more_nodes = data["groups"][group]["classes"]
          if more_nodes:
            result.update(more_nodes)
      else:
        result = data["groups"]['default']["classes"]     
      break
  if result is 'xyz':
    result = data["groups"]['default']["classes"]
  return result
    
if __name__ == "__main__":
    print main();