import dag

fn main() {
    g := dag.new_graph()
    println(g.to_json())
}
