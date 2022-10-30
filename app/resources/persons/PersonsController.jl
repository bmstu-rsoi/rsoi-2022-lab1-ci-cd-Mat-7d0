module PersonsController
  using Lab01.Persons

  using SearchLight
  using Genie.Renderer.Json, Genie.Requests, Genie.Responses

  function index() #Done
    foundPersons = map(SearchLight.all(Person)) do person
      Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person))
    end

    json(:persons, :index, foundPersons=foundPersons)
  end

  function byId() #Done
    foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))) do person
      Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
    end

    if isempty(foundPersons)
      json(:persons, :byId, foundPerson=Dict(:message=>"Person not found"), status = 404)
    else
      json(:persons, :byId, foundPerson=foundPersons[1])
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
    payload = jsonpayload()

    if all(keys(payload) .∈ (["name", "work", "age", "address", "id"],)) &&
    length(payload) == 5
    id = payload["id"]
      foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(id)", 0))) do person
        Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
      end
      if isempty(foundPersons)
        json(Dict(:message=>"Person not found"), status = 404)
      else
        person = Person(name=payload["name"], 
                    work=payload["work"],
                    age=payload["age"],
                    address=payload["address"],
                    id=id)
        save(person)
        foundPersons = map(SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(id)", 0))) do person
          Dict(key=>if key != :id getfield(person, key) else getfield(getfield(person, key), :value) end for key ∈ fieldnames(Person)) 
        end
        json(foundPersons[1])
      end
    else

      additionalProps = Dict()
      for key in keys(payload)
        if !(key in ["name", "work", "age", "address", "id"])
          additionalProps[key] = payload[key]
        end
      end

      errorMsg = Dict(:errors=>additionalProps, :message=>"Invalid data")
      json(errorMsg, status=400)
    end
  end

  function delete()
    foundPersons = SearchLight.find(Person, SearchLight.SQLWhereExpression("id = $(payload(:id))", 0))

    if !isempty(foundPersons)
      SearchLight.delete(foundPersons[1])
    end
    setstatus(204)
  end

end
