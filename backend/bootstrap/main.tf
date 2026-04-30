provider "aws" {
  region = var.region
}

#creation of S3 bucket for storing artifacts for each environment
resource "aws_s3_bucket" "dev_artifact_bucket" {
  bucket = "dev-artifact-bucket"

  tags = {
    Name        = "sohail-artifacts-dev"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "qa_artifact_bucket" {
  bucket = "qa-artifact-bucket"

  tags = {
    Name        = "sohail-artifacts-qa"
    Environment = "qa"
  }
}

resource "aws_s3_bucket" "prod_artifact_bucket" {
  bucket = "prod-artifact-bucket"

  tags = {
    Name        = "sohail-artifacts-prod"
    Environment = "prod"
  }

}

# version enabling for S3 bucket 
resource "aws_s3_bucket_versioning" "dev-bucket-versioning" {
  bucket = aws_s3_bucket.dev_artifact_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "qa-bucket-versioning" {
  bucket = aws_s3_bucket.qa_artifact_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "prod-bucket-versioning" {
  bucket = aws_s3_bucket.prod_artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

#create a KMS key 
resource "aws_kms_key" "dev_s3_key" {
  description             = "KMS key for dev S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}


resource "aws_kms_key" "qa_s3_key" {
  description             = "KMS key for QA S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "prod_s3_key" {
  description             = "KMS key for PROD S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}


#SSE-KMS Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dev_bucket_sse" {
  bucket = aws_s3_bucket.dev_artifact_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.dev_s3_key.arn
    }
    bucket_key_enabled = true #reduces KMS API Call cost
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "qa_bucket_sse" {
  bucket = aws_s3_bucket.qa_artifact_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.qa_s3_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_bucket_sse" {
  bucket = aws_s3_bucket.prod_artifact_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.prod_s3_key.arn
    }
    bucket_key_enabled = true
  }
}

#S3 bucket for storing terraform state files
resource "aws_s3_bucket" "s3_dev_statefile_storeage" {
  bucket = "sohail-tfstate-dev"
  tags = {
    Name        = "sohail-tfstate-dev"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "qa_statefile_storage" {
  bucket = "sohail-tfstate-qa"
  tags = {
    Name        = "sohail-tfstate-qa"
    Environment = "qa"
  }
}

resource "aws_s3_bucket" "prod_statefile_storage" {
  bucket = "sohail-tfstate-prod"
  tags = {
    Name        = "sohail-tfstate-prod"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_versioning" "dev_statefile_versioning" {
  bucket = aws_s3_bucket.s3_dev_statefile_storeage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "qa_statefile_versioning" {
  bucket = aws_s3_bucket.qa_statefile_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "prod_statefile_versioning" {
  bucket = aws_s3_bucket.prod_statefile_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}



# add KMS key encryption for state file buckets
resource "aws_kms_key" "dev_statefile_key"{
  description = "KMS key for dev terraform state file bucket"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_kms_key" "qa_statefile_key"{
  description = "KMS key for qa terraform state file bucket"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_kms_key" "prod_statefile_key"{
  description = "KMS key for prod terraform state file bucket"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

# SSE for all state file buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "dev_statefile_sse" {
  bucket = aws_s3_bucket.s3_dev_statefile_storeage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.dev_statefile_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "qa_statefile_sse" {
  bucket = aws_s3_bucket.qa_statefile_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.qa_statefile_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_statefile_sse" {
  bucket = aws_s3_bucket.prod_statefile_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.prod_statefile_key.arn
    }
    bucket_key_enabled = true
  }
}

#Dynamodb Table for state locking

resource "aws_dynamodb_table" "dev_terraform_state_lock" {
  name         = "dev-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  #enabled PITR for backup
  point_in_time_recovery {
    enabled = true
  }
  #server-side encryption for dynamodb
  server_side_encryption {
    enabled = true
  }
  tags = {
    Name        = "dev-terraform-state-lock"
    Environment = "dev"
  }
}

resource "aws_dynamodb_table" "qa_terraform_state_lock" {
  name         = "qa-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "qa-terraform-state-lock"
    Environment = "qa"
  }

}

resource "aws_dynamodb_table" "prod_terraform_state_lock" {
  name         = "prod-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled = true
  }
  tags = {
    Name        = "prod-terraform-state-lock"
    Environment = "prod"
  }
}
