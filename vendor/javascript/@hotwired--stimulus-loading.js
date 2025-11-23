import { Application } from "@hotwired/stimulus"

export function eagerLoadControllersFrom(path, application) {
  const modules = import.meta.glob("/app/javascript/controllers/**/*_controller.js", { eager: true })
  for (const [modulePath, module] of Object.entries(modules)) {
    const name = modulePath
      .match(/controllers\/(.+)_controller\.js$/)[1]
      .replace(/\//g, "--")
      .replace(/_/g, "-")
    application.register(name, module.default)
  }
}

export function lazyLoadControllersFrom(path, application) {
  const modules = import.meta.glob("/app/javascript/controllers/**/*_controller.js")
  for (const [modulePath, importModule] of Object.entries(modules)) {
    const name = modulePath
      .match(/controllers\/(.+)_controller\.js$/)[1]
      .replace(/\//g, "--")
      .replace(/_/g, "-")
    application.lazyRegister(name, importModule)
  }
}
