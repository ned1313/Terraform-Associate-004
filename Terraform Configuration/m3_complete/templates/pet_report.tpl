Pet Report
==========

Pet name | Length
%{ for pet in pets ~}
${pet.id} | ${pet.length}
%{ endfor ~}

Generated on ${timestamp}