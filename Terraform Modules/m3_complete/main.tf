module "pet_report" {
  source = "./modules/pet_report"

  pet_type = var.pet_type
  pets     = module.pet-registry.pets
}

module "pet-registry" {
  source  = "ned1313/pet-registry/random"
  version = ">=1.0.0"

  pet_type      = var.pet_type
  quantity      = var.quantity
}