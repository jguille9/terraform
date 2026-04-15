# Declarem el provider local explícitament
# Això és una bona pràctica: sempre especifica la versió del provider
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Variable per parametritzar el missatge
# Permet canviar el contingut sense modificar el codi principal
variable "missatge" {
  description = "El missatge que s'escriurà al fitxer generat"
  type        = string
  default     = "Hola! Aquest fitxer ha estat creat automàticament per Jenkins i Terraform."
}

# El recurs principal: un fitxer de text
# 'local_file' és el tipus de recurs del provider local
# 'missatge' és el nom que li donem nosaltres a aquesta instància
resource "local_file" "missatge" {
  content  = var.missatge
  filename = "${path.module}/missatge.txt"

  # Assegurem que el fitxer té permisos de lectura estàndard
  file_permission = "0644"
}

# Output: informació útil que Terraform mostrarà després de l'apply
output "ruta_fitxer_creat" {
  description = "La ruta completa del fitxer generat per Terraform"
  value       = local_file.missatge.filename
}

output "contingut_fitxer" {
  description = "El contingut que s'ha escrit al fitxer"
  value       = local_file.missatge.content
}