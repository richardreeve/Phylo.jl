module TestNewick

using Phylo
using Compat.Test

@testset "A few simple binary trees" begin
    @test length(nodeiter(parsenewick("((,),(,));"))) == 7
    @test ["where", "when it's good", "Not mine", "MyLeaf"] ⊆
        nodenameiter(parsenewick("""((MyLeaf,"when it's good"),
                                     ('Not mine',where));"""))
    tree = parsenewick("((MyLeaf[&Real=23,'Not real'={5,4}]:4.0,)Parent,(,));")
    branches = branchfilter(tree) do branch
        return src(branch) == "Parent" && dst(branch) == "MyLeaf"
    end
    @test length(branches) == 1
    @test getlength(first(branches)) ≈ 4.0
    @test getnoderecord(tree, "MyLeaf")["Real"] == 23
    @test 5 ∈ getnoderecord(tree, "MyLeaf")["Not real"]
    @test 4 ∈ getnoderecord(tree, "MyLeaf")["Not real"]
    @test_throws ErrorException parsenewick("((,),(,)));")
    @test_throws ErrorException parsenewick("((,),(,))")
    if VERSION < v"0.7.0-"
        @test_throws ErrorException parsenewick("((,),(,);")
    else
        @test_throws UndefRefError parsenewick("((,),(,);")
    end
    @test_throws ErrorException parsenewick("((MyLeaf:-4.0,)Parent,(,));")
end

@testset "A few simple polytomous trees" begin
    @test length(nodeiter(parsenewick("((,),(,,));", NamedPolytomousTree))) == 8
    @test ["where", "when it's good", "Not mine", "MyLeaf", "next"] ⊆
        nodenameiter(parsenewick("""((MyLeaf,"when it's good",next),
                                     ('Not mine',where));""", NamedPolytomousTree))
    tree = parsenewick("((MyLeaf:4.0,)Parent,());", NamedPolytomousTree)
    branches = branchfilter(tree) do branch
        return src(branch) == "Parent" && dst(branch) == "MyLeaf"
    end
    @test length(branches) == 1
    @test getlength(first(branches)) ≈ 4.0
    @test_throws ErrorException parsenewick("((,),(,)));", NamedPolytomousTree)
    @test_throws ErrorException parsenewick("((,),(,))", NamedPolytomousTree)
    if VERSION < v"0.7.0-"
        @test_throws ErrorException parsenewick("((,),(,);", NamedPolytomousTree)
    else
        @test_throws UndefRefError parsenewick("((,),(,);", NamedPolytomousTree)
    end
end

end
