# Consumer-source relationships retained from the supplied analysis.
model_specs <- list(
  list(
    consumer = "Fish | Primary Consumer",
    sources = c("Detritus", "Phytoplankton", "Macrophytes", "Periphyton")
  ),
  list(
    consumer = "Fish | Invertivore",
    sources = c("Detritus", "Allochthonous insects", "Aquatic macroinvertebrates")
  ),
  list(
    consumer = "Fish | Omnivore",
    sources = c(
      "Detritus",
      "Phytoplankton",
      "Allochthonous insects",
      "Macrophytes",
      "Aquatic macroinvertebrates"
    )
  ),
  list(
    consumer = "Fish | Carnivore-piscivore",
    sources = c(
      "Fish | Primary Consumer",
      "Fish | Invertivore",
      "Fish | Omnivore"
    )
  ),
  list(
    consumer = "Birds | Invertivore",
    sources = c("Allochthonous insects", "Aquatic macroinvertebrates")
  ),
  list(
    consumer = "Birds | Omnivore",
    sources = c(
      "Allochthonous insects",
      "Aquatic macroinvertebrates",
      "Allochthonous plants"
    )
  ),
  list(
    consumer = "Birds | FrugiGranivore",
    sources = c(
      "Allochthonous plants",
      "Allochthonous insects"
    )
  ),
  list(
    consumer = "Birds | Nectarivore",
    sources = c(
      "Allochthonous plants",
      "Aquatic macroinvertebrates",
      "Allochthonous insects"
    )
  ),
  list(
    consumer = "Birds | Aquatic predator",
    sources = c(
      "Fish | Primary Consumer",
      "Fish | Invertivore",
      "Fish | Omnivore",
      "Aquatic macroinvertebrates"
    )
  )
)

