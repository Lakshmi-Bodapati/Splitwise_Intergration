variable "Region" {
  type = string
  description = "Region for this infra"
}

variable "Bucket" {
  type = string
  description = "Enter Name of Bucket which has gsheets JSON File"
}

variable "Bucket_key" {
  type = string
  description = "Enter path to the JSON file in the bucket"
}

variable "CRON" {
    type = string
    description = "Schedule at which sequence lambda should be running"
}

variable "split-key" {
    type = string
    description = "Splitwise API Key"
}

variable "Gsheet-name" {
    type = string
    description = "Enter Name of your google sheets"
}

variable "Place-to-insert" {
    type = string
    description = "Coloum to insert the value"
}

variable "State-Bucket" {
    type = string
    description = "Terraform state bucket in S3"
}