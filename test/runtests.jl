using JuliaCoin, Test

    @testset "create_origin_block" begin
        @test create_origin_block() isa Blockchain
    end

    @testset "new_transaction" begin
        blockchain = create_origin_block()
        # Test that new index is greater than last one
        @test new_transaction(blockchain, "sender", "recipient", 50) > blockchain.chain[end].index
        # Test that giving a wrong typing for blockchain returns MethodError
        @test_throws MethodError new_transaction("blockchain", "sender", "recipient", 50)
    end
    @testset "valid_proof" begin
        @test valid_proof(0, 0) isa Bool
        @test_throws MethodError valid_proof("hi", 0)
        @test valid_proof(0, 5735) == 1
        @test valid_proof(0, 1) == 0
    end

    @testset "proof_of_work" begin
        @test proof_of_work(0) isa Int
        @test_throws MethodError proof_of_work("0")
        @test_throws MethodError proof_of_work(-1)
    end

    @testset "last_block" begin
        blockchain = create_origin_block()
        @test last_block(blockchain) isa Block
        @test_throws MethodError last_block(1)
        @test_throws MethodError last_block("blockchain")
    end