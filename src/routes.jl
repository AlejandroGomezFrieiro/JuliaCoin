# HTTP server for JuliCoin
using JuliaCoin
using Genie, Genie.Router, Genie.Renderer.Json, Genie.Requests
using HTTP
using UUIDs
import JSON

# Generate a unique address for the node
node_identifier = uuid4() |> string

blockchain = create_origin_block()

route("/mine", method = GET) do
  # Run proof of work algorithm
  last_block = blockchain.chain[end]
  last_proof = last_block.proof
  proof = proof_of_work(last_proof)

  # We must receive a reward for finding the proof.
  # The sender is "0" to signify that this node has mined a new coin.
  new_transaction(blockchain, "0", node_identifier, 1)

  previous_hash = JuliaCoin.hash(last_block)
  block = JuliaCoin.new_block(blockchain, proof, previous_hash)

  response = Dict(
        "message"=> "New Block Forged",
        "index"=> block.index,
        "transactions"=> block.transactions,
        "proof"=> block.proof,
        "previous_hash"=> block.previous_hash,
  )
  json(response)
end

route("/chain", method = GET) do 
    response = Dict(
        "chain" => blockchain.chain,
        "length" => length(blockchain.chain),
    )
    response |> JSON.json
end

route("/transactions/new", method = POST) do 
  # Return the JSON request
  data = jsonpayload()
  print(keys(data))
  requested_keys = ["sender", "recipient", "amount"]
  # Check that requested data has the proper keys, else return an error
  if !(length(keys(data))==length(requested_keys) && all(k->in(k,requested_keys), keys(data)))
      "Missing values" |> json
  end
  # Create a new Transaction
  index = new_transaction(blockchain, data["sender"], data["recipient"], data["amount"])

  response = Dict("message" => "Transaction will be added to Block $index")
  json(response)
end

route("/send") do
  response = HTTP.request("POST", "http://localhost:8000/transactions/new", [("Content-Type", "application/json")], """{"sender":"hello", "recipient":"thanks", "amount":1}""")

  response.body |> String |> json
end

Genie.startup(async = false)