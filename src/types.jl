using Dates

struct Transaction
        sender::String
        recipient::String
        amount::Int
    end

struct Block
    index::Int
    timestamp::Dates.DateTime
    transactions::Array{Transaction}
    proof::Int
    previous_hash::String
end

mutable struct Blockchain
    chain::Array{Block}
    current_transactions::Array{Transaction}
end