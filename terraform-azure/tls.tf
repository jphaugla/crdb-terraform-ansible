locals {
  tls_private_key = coalesce(var.tls_private_key, tls_private_key.crdb_ca_keys.private_key_pem)
  tls_public_key  = coalesce(var.tls_public_key, tls_private_key.crdb_ca_keys.public_key_pem)
  tls_cert        = coalesce(var.tls_cert, tls_self_signed_cert.crdb_ca_cert.cert_pem)
  tls_user_cert   = coalesce(var.tls_user_cert, tls_locally_signed_cert.user_cert.cert_pem)
  tls_user_key    = coalesce(var.tls_user_key, tls_private_key.client_keys.private_key_pem)
}

resource "local_file" "write_tls_cert" {
   filename = "${var.playbook_working_directory}/temp/${var.virtual_network_location}/tls_cert"
   content = local.tls_cert
}
resource "local_file" "write_tls_user_cert" {
   filename = "${var.playbook_working_directory}/temp/${var.virtual_network_location}/tls_user_cert"
   content = local.tls_user_cert
}
resource "local_file" "write_tls_user_key" {
   filename = "${var.playbook_working_directory}/temp/${var.virtual_network_location}/tls_user_key"
   content = local.tls_user_key
}
resource "local_file" "write_tls_private_key" {
   filename = "${var.playbook_working_directory}/temp/${var.virtual_network_location}/tls_private_key"
   content = local.tls_private_key
}
resource "local_file" "write_tls_public_key" {
   filename = "${var.playbook_working_directory}/temp/${var.virtual_network_location}/tls_public_key"
   content = local.tls_public_key
}


# -----------------------------------------------------------------------
#  CRDB Keys and ca.crt
# -----------------------------------------------------------------------
# Create both the keys and cert required for secure mode
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#private_key_openssh
resource "tls_private_key" "crdb_ca_keys" {
  algorithm = "RSA"
  rsa_bits  = 2048 
}

# https://www.cockroachlabs.com/docs/v22.2/create-security-certificates-openssl
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert
# also created cert with : su - ec2-user -c 'openssl req -new -x509 -key my-safe-directory/ca.key -out certs/ca.crt -days 1831 -subj "/O=Cockroach /CN=Cockroach CA /keyUsage=critical,digitalSignature,keyEncipherment /extendedKeyUsage=clientAuth"'
resource "tls_self_signed_cert" "crdb_ca_cert" {
  private_key_pem = tls_private_key.crdb_ca_keys.private_key_pem

  subject {
    common_name  = "Cockroach CA"
    organization = "Cockroach"
  }

  validity_period_hours = 45000
  is_ca_certificate = true

  allowed_uses = [
    "any_extended",
    "cert_signing",
    "client_auth",
    "code_signing",
    "content_commitment",
    "crl_signing",
    "data_encipherment",
    "digital_signature",
    "email_protection",
    "key_agreement",
    "key_encipherment",
    "ocsp_signing",
    "server_auth"
  ]
}

# -----------------------------------------------------------------------
# Client Keys and cert
# -----------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#private_key_openssh
resource "tls_private_key" "client_keys" {
  algorithm = "RSA"
  rsa_bits  = 2048 
}

resource "tls_cert_request" "client_csr" {
  private_key_pem = tls_private_key.client_keys.private_key_pem

  subject {
    organization = "Cockroach"
    common_name = "${var.dbadmin_user_name}"
  }

  dns_names = ["root"]

}

resource "tls_locally_signed_cert" "user_cert" {
  cert_request_pem = tls_cert_request.client_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.crdb_ca_keys.private_key_pem
  ca_cert_pem = tls_self_signed_cert.crdb_ca_cert.cert_pem

  validity_period_hours = 43921

    allowed_uses = [
    "any_extended",
    "cert_signing",
    "client_auth",
    "code_signing",
    "content_commitment",
    "crl_signing",
    "data_encipherment",
    "digital_signature",
    "email_protection",
    "key_agreement",
    "key_encipherment",
    "ocsp_signing",
    "server_auth"
  ]
}
