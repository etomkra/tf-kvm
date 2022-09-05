#!/usr/bin/python
import sys 
import json

def ask(content):
    tf_query = json.loads(content)
    if "query" in tf_query:
        topo_file = tf_query["topology_file"]
        with open("{}".format(topo_file), "r") as f:
            topology = json.load(f)
        operation = globals()[tf_query["query"]]
    res = json.dumps(operation(topology, **tf_query))
    return res


def get_vm_data(topology, **kwargs):
    result = {}
    for n in topology["vms"]:
        if n["hostname"]:
            result[n["hostname"]] = n["mgmt_ip"]
    return result

if __name__ == "__main__":
    query = sys.stdin.read()
    print(ask(query))
