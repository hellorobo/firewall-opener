import json
import os
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
from flask import abort, jsonify, make_response
import dns.resolver
from google.cloud import error_reporting


def getNsRecord(url, nameserver='8.8.8.8'):
      recordtype = 'NS'

      resolver = dns.resolver.Resolver(configure=False)
      resolver.nameservers = [nameserver]
      nsrecord = []
      while '.' in url:
          try:
              answer = resolver.query(url, recordtype)
          except (KeyError, dns.resolver.NoAnswer):
              url = url[url.find('.')+1::]
              continue
          except Exception as e:
              print("## Unexpected error occured!")
              raise e
          else:
              for rr in answer:
                  rrs = (str(rr.target)).rstrip('.')
                  nsrecord.append(rrs)
              break
      return nsrecord

def resolveFqdns(fqdns, nameserver='8.8.8.8'):
      recordtype = 'A'

      resolver = dns.resolver.Resolver(configure=False)
      resolver.nameservers = [nameserver]
      aRecords = []
      for f in fqdns:
          try:
              answer = resolver.query(f, recordtype)
          except Exception as e:
              print("## Unexpected error occured!")
              raise e
          else:
              for rr in answer:
                  aRecords.append(rr)
      return aRecords

def getARecord(fqdn, dnsips):
      recordtype = 'A'

      resolver = dns.resolver.Resolver(configure=False)
      str_dnsips = []
      for ip in dnsips:
          str_dnsips.append(f"{ip}")
      resolver.nameservers = str_dnsips
      cidr = ''
      try:
          answer = resolver.query(fqdn, recordtype)
      except Exception as e:
          print("## Unexpected error occured!")
          raise e
      for rr in answer:
          cidr = str(rr)
      return cidr

def updateFw(request):

    client = error_reporting.Client()

    try:
      request_json = request.get_json()
      request_method = request.method
      print (f"Received request: {json.dumps(request_json)}")

      auth_token = request.headers['Authorization'].replace('Bearer ','')
      if (os.environ['AUTH_BEARER_TOKEN'] == auth_token) and (request_method == os.environ['REST_METHOD']):
        project = os.environ['PROJECT']
        firewall = os.environ['FW_RULE']
        ddns = os.environ['DDNS']
        received_cidr = request_json['cidr']

        # get cidr from dynamic dns service provider
        dns_servers = getNsRecord(ddns)
        dns_ips = resolveFqdns(dns_servers)
        cidr_from_dns = getARecord(ddns, dns_ips)+'/32'

        # compare recevived_cidr with cidr_from_dns
        if cidr_from_dns == received_cidr:

          credentials = GoogleCredentials.get_application_default()
          service = discovery.build('compute', 'v1', credentials=credentials)

          # get current fw settings
          handler = service.firewalls().get(project=project, firewall=firewall)
          fw_settings = handler.execute()

          # remove unwanted fields
          try:
            del fw_settings['id']
            del fw_settings['creationTimestamp']
            del fw_settings['sourceRanges']
          except KeyError:
            pass
          
          fw_settings['sourceRanges'] = [cidr_from_dns]

          handler = service.firewalls().update(project=project, firewall=firewall, body=fw_settings)
          response = handler.execute()

          if 'httpErrorStatusCode' not in response:
            return make_response(jsonify({'success':True}), 200)
          else:
            return make_response(jsonify({'error':response['httpErrorMessage']}), response['httpErrorStatusCode'])
        else:
          return abort(412) # http error: Precondition Failed
      else:
        return abort(401) # http error: Unauthorized
    except:
      client.report_exception()
      return abort(500) # internal error