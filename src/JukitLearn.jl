# IMPORTANT NOTE: Most of the codebase is in the module Skcore. ScikitLearn is
# defined here by importing from Skcore and reexporting what we want in the
# interface. This arrangement simplifies the codebase and allows us to
# experiment with different submodule structures without breaking everything.

include("Skcore.jl")


module JukitLearn

import Skcore

using PyCall: @pyimport
using JukitLearnBase
using Skcore: @sk_import

export CrossValidation, @sk_import


################################################################################

macro reexport(module_, identifiers...)
    esc(:(begin
        $([:(begin
             using $module_: $idf
             export $idf
             end)
        for idf in identifiers]...)
    end))
end

"""    @reexportsk(identifiers...)
is equivalent to
    using Skcore: identifiers...
    export identifiers...
"""
macro reexportsk(identifiers...)
    :(@reexport($(esc(:Skcore)), $(map(esc, identifiers)...)))
end


## module LinearModels
## using ..@reexport
## using PyCall: @pyimport
## @pyimport sklearn.linear_model as _linear_model
## for var in names(_linear_model)
##     if isa(var, Symbol) && string(var)[1] != '_'
##         @eval const $var = _linear_model.$var
##     end
## end
## end


module CrossValidation
using ..@reexportsk, ..@sk_import
using Skcore: @pyimport2
import Skcore
@reexportsk(cross_val_score, cross_val_predict)
@pyimport2 sklearn.cross_validation: train_test_split
export train_test_split

@eval @reexportsk($(Skcore.cv_iterator_syms...))
end


module Pipelines
using ..@reexportsk
@reexportsk(Pipeline, make_pipeline, FeatureUnion, named_steps)
end


module GridSearch
using ..@reexportsk
@reexportsk(GridSearchCV, RandomizedSearchCV)
end


module Utils
using ..@reexportsk
using Skcore: @pyimport2
@reexportsk(meshgrid)
export @pyimport2
end

## @pyimport sklearn.ensemble as Ensembles
## @pyimport sklearn.datasets as Datasets
## @pyimport sklearn.tree as Trees


################################################################################
# Other exports

# Not sure if we should export all the api. set_params!/get_params are rarely
# used by user code.
for f in JukitLearnBase.api @eval(@reexportsk $f) end

end