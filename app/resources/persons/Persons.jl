module Persons

import SearchLight: AbstractModel, DbId
import Base: @kwdef

export Person

@kwdef mutable struct Person <: AbstractModel
  id::DbId = DbId()
  name::String = ""
  work::String = ""
  age::Int = 0
  address::String = ""
end

end