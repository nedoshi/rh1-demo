#!/usr/bin/env python3
"""
Simple Kubernetes Validating Admission Webhook Server
Checks deployments for vulnerability annotations and blocks if vulnerable
"""

import json
import os
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
import ssl
import base64

# Load vulnerability database from environment
VULNERABILITY_DB = os.getenv('VULNERABILITY_DB', '{}')
try:
    VULN_DATA = json.loads(VULNERABILITY_DB)
except:
    VULN_DATA = {}

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/validate':
            self.handle_validate()
        elif self.path == '/health':
            self.handle_health()
        else:
            self.send_error(404)
    
    def handle_health(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "healthy"}).encode())
    
    def handle_validate(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            admission_review = json.loads(post_data.decode('utf-8'))
            request = admission_review.get('request', {})
            
            # Extract deployment information
            object_data = request.get('object', {})
            metadata = object_data.get('metadata', {})
            annotations = metadata.get('annotations', {})
            labels = metadata.get('labels', {})
            
            # Check for vulnerability indicators
            allowed = True
            message = "Deployment allowed"
            
            # Check for CVE annotation
            cve_detected = annotations.get('cve.detected', '')
            if cve_detected and cve_detected != 'none':
                allowed = False
                message = f"Deployment blocked: Critical vulnerability detected ({cve_detected})"
            
            # Check for malicious label
            if labels.get('malicious') == 'true' or labels.get('vulnerable') == 'true':
                allowed = False
                message = "Deployment blocked: Malicious or vulnerable deployment detected"
            
            # Check for missing signature verification
            signature_verified = annotations.get('signature.verified', '')
            if signature_verified == 'false':
                allowed = False
                message = "Deployment blocked: Image signature not verified"
            
            # Check vulnerability scan annotation
            vuln_scan = annotations.get('vulnerability.scan', '')
            if vuln_scan == 'true' and annotations.get('cve.detected', '') != 'none':
                allowed = False
                message = "Deployment blocked: Vulnerability scan detected issues"
            
            # Create response
            uid = request.get('uid', '')
            response = {
                "apiVersion": "admission.k8s.io/v1",
                "kind": "AdmissionReview",
                "response": {
                    "uid": uid,
                    "allowed": allowed,
                    "status": {
                        "code": 200 if allowed else 403,
                        "message": message
                    }
                }
            }
            
            # Log the decision
            print(f"[{self.client_address[0]}] Deployment: {metadata.get('name', 'unknown')} - {'ALLOWED' if allowed else 'BLOCKED'}: {message}")
            
            # Send response
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
            
        except Exception as e:
            print(f"Error processing request: {e}", file=sys.stderr)
            self.send_error(500, str(e))
    
    def log_message(self, format, *args):
        # Custom logging
        print(f"[{self.client_address[0]}] {format % args}")

def main():
    port = int(os.getenv('WEBHOOK_PORT', '8443'))
    cert_file = os.getenv('TLS_CERT_FILE', '/etc/certs/tls.crt')
    key_file = os.getenv('TLS_KEY_FILE', '/etc/certs/tls.key')
    
    server = HTTPServer(('0.0.0.0', port), WebhookHandler)
    
    # Setup SSL if certificates exist
    if os.path.exists(cert_file) and os.path.exists(key_file):
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cert_file, key_file)
        server.socket = context.wrap_socket(server.socket, server_side=True)
        print(f"Webhook server starting with TLS on port {port}")
    else:
        print(f"WARNING: Certificates not found, starting without TLS on port {port}")
        print(f"  Cert file: {cert_file}")
        print(f"  Key file: {key_file}")
    
    print("Vulnerability Validator Webhook Server ready")
    print(f"Vulnerability database loaded: {len(VULN_DATA)} entries")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down webhook server...")
        server.shutdown()

if __name__ == '__main__':
    main()

