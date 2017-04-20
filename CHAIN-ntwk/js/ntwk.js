var svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");

var color = d3.scaleOrdinal(d3.schemeCategory20);

var simulation = d3.forceSimulation()
  .force("link", d3.forceLink().id(function(d) { return d.id; }))
  .force("charge", d3.forceManyBody().strength(-2250))
  .force("center", d3.forceCenter(width / 2, height / 2));

d3.csv("./data/20170414_IP_nodes.csv", function(error, nodeData) {
  if (error) throw error;
  d3.csv("./data/20170414_IP_edges.csv", function(error, edgeData) {
    if (error) throw error;


nodeData.forEach(function(d){
  d.total = +d.total;
  d.unique = +d.unique;
});


edgeData.forEach(function(d){
  d.value = +d.n;
});

allIPs = nodeData.map(function(element) {return element.id});

  if (error) throw error;

  var graph = {};

  graph.nodes = nodeData;
  graph.links = edgeData;


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

    // Define the div for the tooltip
var divNode = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("width", "125px")
    .style("height", "18px")
    .style("opacity", 0);

var divEdge = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("width", "50px")
    .style("height", "18px")
    .style("opacity", 0);

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

// -- TOOLTIPS (nodes) --

  node.on("mouseover", function(sel) {

    linked = edgeData.filter(function(d) { return d.source.id == sel.id | d.target.id == sel.id})
    linkedSources = linked.map(function(element) {return element.source.id});
    linkedTargets = linked.map(function(element) {return element.target.id});

    selIPs = linkedTargets.concat(linkedSources);


    link.transition()
      .style("opacity", 1)
    .filter(function(d) { return d.source.id != sel.id & d.target.id != sel.id;})
        .duration(200)
        .style("opacity", 0.1);


    node.style("opacity", 0.9)
    .transition()
    // .filter(function(d, i) { console.log(d.id); console.log(sel.id == "AEE"); sel.id == "AEE";})
      .filter(function(d, i) { return !selIPs.includes(d.id);})
      .duration(200)
      .style("opacity", 0.25)

    divNode.transition()
        .duration(200)
        // .style("background", color(d.id))
        // .style("background")
        // .attr("fill", function(d) { return color(d.id); })
        .style("opacity", 0.85);
    // divNode.html(sel.id + " works with <br/>" + sel.unique + " partners")
    divNode.html(sel.unique + " partnerships")
        .style("color", color(sel.id))
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px");
    })
.on("mouseout", function(d) {
    divNode.transition()
        .duration(500)
        .style("opacity", 0);

  link.transition()
      .duration(200)
      .style("opacity", 0.6);

    node.transition()
          .duration(500)
          .style("opacity", 0.9)
});


// -- edge tooltip --
      link.on("mouseover", function(sel) {
  // grey out edges
        link.style("opacity", 1)
        .transition()
        .filter(function(d) { return d.source != sel.source | d.target != sel.target;})
            .duration(200)
            .style("opacity", 0.1);


  // grey out nodes
        node.style("opacity", 0.9)
        .transition()
        .filter(function(d) { return d.id != sel.source.id & d.id != sel.target.id;})
            .duration(200)
            .style("opacity", 0.1);
        //
        // node.transition()
        // .filter(function(d) { return d.id == sel.source.id | d.id == sel.target.id;})
        //     .duration(200)
        //     .style("opacity", 0.9);

    // tooltip
        divEdge.transition()
            .duration(200)
            .style("opacity", 0.85);
        divEdge.html(sel.value + " tasks")
            .style("left", (d3.event.pageX) + "px")
            .style("top", (d3.event.pageY - 28) + "px");
        })
    .on("mouseout", function(d) {
              link.transition()
                  .duration(500)
                  .style("opacity", 1);

        divEdge.transition()
            .duration(500)
            .style("opacity", 0);

      node.transition()
          .duration(500)
          .style("opacity", 0.9);

      link.transition()
          .duration(500)
          .style("opacity", 0.6);
    });


  var labels = svg.selectAll("#ip-labels")
  .data(graph.nodes)
  .enter().append("text")
    .attr("id", "ip-labels")
    .style("font-size", "15px")
        .style("text-anchor", "middle")
        .style("alignment-baseline", "middle")
        .style("fill", "black")
        .style("z-index", 0)
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
