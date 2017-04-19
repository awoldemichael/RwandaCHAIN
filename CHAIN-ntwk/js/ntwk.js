var svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");

var color = d3.scaleOrdinal(d3.schemeCategory20);

var simulation = d3.forceSimulation()
  .force("link", d3.forceLink().id(function(d) { return d.id; }))
  .force("charge", d3.forceManyBody().strength(-1000))
  .force("center", d3.forceCenter(width / 2, height / 2));

d3.csv("data/20170414_IP_nodes.csv", function(error, nodeData) {
  if (error) throw error;
  d3.csv("data/20170414_IP_edges.csv", function(error, edgeData) {
    if (error) throw error;


nodeData.forEach(function(d){
  d.total = +d.total;
  d.unique = +d.unique;
});


edgeData.forEach(function(d){
  d.value = +d.n;
});



  if (error) throw error;

  var graph = {};

  graph.nodes = nodeData;
  graph.links = edgeData;

console.log(graph)

svg.append("text")
  .attr("class", "title")
  .attr("id", "main-title")
  .attr("x", 35)
  .attr("y", 35)
  .text("Collaborations between Partners in 2017 CHAIN Integrated Work Plan");

  svg.append("text")
    .attr("class", "annotation")
    .attr("id", "edge-expl")
    .attr("x", 35)
    .attr("y", 95)
    .text("Circles are larger if the IP is working with more partners")

  svg.append("text")
    .attr("class", "annotation")
    .attr("id", "edge-expl")
    .attr("x", 35)
    .attr("y", 125)
    .text("Lines are fatter the more collaborations the two partners are planning to do");

  svg.append("text")
    .attr("class", "annotation")
    .attr("id", "edge-expl")
    .attr("x", 35)
    .attr("y", 155)
    .text("Click and drag a circle to pull apart the nest");

  var link = svg.append("g")
      .attr("class", "links")
    .selectAll("line")
    .data(graph.links)
    .enter().append("line")
      // .attr("stroke", function(d) { return color(d.source); })
      .attr("stroke-width", function(d) { return (d.value * 2); });

  var node = svg.append("g")
      .attr("class", "nodes")
    .selectAll("circle")
    .data(graph.nodes)
    .enter().append("circle")
      .attr("r", function(d) { return d.unique * 3;})
      .attr("fill", function(d) { return color(d.id); })
      .attr("opacity", 0.9)
      .call(d3.drag()
          .on("start", dragstarted)
          .on("drag", dragged)
          .on("end", dragended));

  var labels = svg.selectAll("#ip-labels")
  .data(graph.nodes)
  .enter().append("text")
    .attr("id", "ip-labels")
    .style("font-size", "15px")
    // .append("text")
        // .attr("class", "source")
        // .attr("id", "email")
        // .attr("x", function(d) { console.log(d.x); return d.x; })
        // .attr("y", function(d) { return d.y; })
        // .attr("y", 100)
        // .attr("x", 100)
        .style("text-anchor", "middle")
        .style("alignment-baseline", "middle")
        // .text("geocenter@usaid.gov")
        .style("fill", "black")
        .style("z-index", 1000)
      .text(function(d) { return d.id; });

  simulation
      .nodes(graph.nodes)
      .on("tick", ticked);

  simulation.force("link")
      .links(graph.links);

  function ticked() {
    link
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });

    labels
        .attr("x", function(d) { return d.x; })
        .attr("y", function(d) { return d.y; });
  }
})
});

function dragstarted(d) {
  if (!d3.event.active) simulation.alphaTarget(0.3).restart();
  d.fx = d.x;
  d.fy = d.y;
}

function dragged(d) {
  d.fx = d3.event.x;
  d.fy = d3.event.y;
}

function dragended(d) {
  if (!d3.event.active) simulation.alphaTarget(0);
  d.fx = null;
  d.fy = null;
}
