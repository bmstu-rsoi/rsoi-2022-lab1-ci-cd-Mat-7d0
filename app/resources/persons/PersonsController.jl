module PersonsController
  using Lab01.Persons

  using SearchLight
  using Genie.Renderer.Json, Genie.Requests, Genie.Responses

  function index() #Done
    foundPersons = map(SearchLight.all(Person)) do person
      Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person))
    end

    json(foundPersons)
  end

  function byId() #Done
    foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))) do person
      Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
    end

    if isempty(foundPersons)
      json(Dict(:message=>"Person not found"), status = 404)
    else
      json(foundPersons[1])
    end
  end

  function add() #Done
    payload = jsonpayload()

    if all(keys(payload) .∈ (["name", "work", "age", "address"],)) &&
    length(payload) == 4
      person = Person(name=payload["name"], 
                    work=payload["work"],
                    age=payload["age"],
                    address=payload["address"])
      person = SearchLight.save!(person)
      Genie.Responses.setheaders(Dict("Location"=>"/api/v1/persons/$(person.id)"))
      setstatus(201)
    else
      setstatus(400)
    end
  end

  function update() #Done
    jsonpayloadData = jsonpayload()

    additionalProps = Dict()
    for key in keys(jsonpayloadData)
      if key != "name" &&
         key != "work" &&
         key != "age" &&
         key != "address"

         additionalProps[key] = jsonpayloadData[key]
      end
    end
    if !isempty(additionalProps)
      errorMsg = Dict(:errors=>additionalProps, :message=>"Invalid data")
      return json(errorMsg, status=400)
    end

    foundPersons = SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))
      
    if isempty(foundPersons)
      return json(Dict(:message=>"Person not found"), status = 404)
    end

    if "name" in keys(payload)
      foundPersons[1].name = payload["name"]
    end
    if "work" in keys(payload)
      foundPersons[1].work = payload["work"]
    end
    if "age" in keys(payload)
      foundPersons[1].age = payload["age"]
    end
    if "address" in keys(payload)
      foundPersons[1].address = payload["address"]
    end

    foundPersons[1] = save!(foundPersons[1])

    #Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 

    updatedPerson = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))) do person
      Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
    end
    json(updatedPerson[1])
  end

  function delete()
    foundPersons = SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))

    if !isempty(foundPersons)
      SearchLight.delete(foundPersons[1])
    end
    setstatus(204)
  end

end