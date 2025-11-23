export function eagerLoadControllersFrom(under, application) {
  const paths = Object.keys(parseImportmapJson()).filter(path => path.match(new RegExp(`^${under}/.*_controller$`)))
  paths.forEach(path => registerControllerFromPath(path, under, application))
}

export function lazyLoadControllersFrom(under, application) {
  const paths = Object.keys(parseImportmapJson()).filter(path => path.match(new RegExp(`^${under}/.*_controller$`)))
  paths.forEach(path => registerLazyControllerFromPath(path, under, application))
}

function parseImportmapJson() {
  const importmap = document.querySelector("script[type=importmap]")
  return JSON.parse(importmap.text).imports
}

function registerControllerFromPath(path, under, application) {
  const name = path
    .replace(new RegExp(`^${under}/`), "")
    .replace("_controller", "")
    .replace(/_/g, "-")
    .replace(/\//g, "--")

  import(path)
    .then(module => application.register(name, module.default))
    .catch(error => console.error(`Failed to register controller: ${name} (${path})`, error))
}

function registerLazyControllerFromPath(path, under, application) {
  const name = path
    .replace(new RegExp(`^${under}/`), "")
    .replace("_controller", "")
    .replace(/_/g, "-")
    .replace(/\//g, "--")

  application.registerLazy(name, () => import(path).then(m => m.default))
}
