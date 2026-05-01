${type} Pet Report
==========

Pet name${separator}Length
%{ for pet in pets ~}
${pet.id}${separator}${pet.length}
%{ endfor ~}

Generated on ${timestamp}
