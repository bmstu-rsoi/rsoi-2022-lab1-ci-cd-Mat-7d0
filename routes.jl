using Genie.Router

using Lab01.PersonsController
using JSON

# API documentation route
using SwagUI
api_doc = JSON.parsefile("APIdocumentation.json")
route("/api/v1") do
  SwagUI.render_swagger(api_doc)
end

# API realizations
route("/api/v1/persons/:id", PersonsController.delete, method=DELETE)

route("/api/v1/persons/:id", PersonsController.update, method=PATCH)

route("/api/v1/persons/:id", PersonsController.byId, method=GET)

route("/api/v1/persons", PersonsController.add, method=POST)

route("/api/v1/persons", PersonsController.index, method=GET)