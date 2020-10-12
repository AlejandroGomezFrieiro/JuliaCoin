module JuliaCoin

    export Transaction, Blockchain, Block
    export new_transaction, new_block, create_origin_block, hash, valid_proof, proof_of_work, last_block

    include("./types.jl")
    using SHA
    using JSON

    function new_transaction(
        blockchain::Blockchain,
        sender::String,
        recipient::String,
        amount::Int,
    )::Int
        transaction = Transaction(sender, recipient, amount)
        push!(blockchain.current_transactions, transaction)
        return blockchain.chain[end].index + 1
    end

    function new_block(blockchain::Blockchain, proof::Int, previous_hash::String)::Block
        block = Block(blockchain.chain[end].index + 1, Dates.now(), blockchain.current_transactions, proof, previous_hash)
        blockchain.current_transactions = []
        push!(blockchain.chain, block)
        return block
    end

    function create_origin_block()::Blockchain
        origin_block = Block(1, Dates.now(), [], 100, "0")
        blockchain = Blockchain([origin_block], [])
        return blockchain
    end

    function hash(block::Block)::String
        block_string = string(block.index, block.timestamp, block.transactions, block.proof, block.previous_hash)
        return bytes2hex(sha256(block_string))
    end

    function valid_proof(last_proof::Int, proof::Int)::Bool
        guess = "$last_proof$proof"
        guess_hash = bytes2hex(sha256(guess))
        return guess_hash[end-3:end] == "0000"
    end

    function proof_of_work(last_proof::Int)::Int
        proof = 0
        # Check for negative integer
        if last_proof < 0
            throw(MethodError())
        end

        while valid_proof(last_proof, proof) == 0
            proof +=1
        end
        return proof
    end

    function last_block(blockchain::Blockchain)::Block
        return blockchain.chain[end]
    end

end # module
