function hypotenuse(l) = sqrt(pow(l, 2) * 2);
function cathetus(l) = sqrt(pow(l, 2) / 2);

module groove(i, columnWidth, grooveDepth, louvreHeight) {
    
    cutoutLength = hypotenuse(columnWidth) + cathetus(louvreHeight);

    translate([0, 0, i])
        rotate([0, -45, 0])
            cube([cutoutLength, grooveDepth, louvreHeight]);
}

module column(columnWidth, columnHeight, grooveDepth, grooveSeparation, louvreHeight, louvreDepth, louvreCount, backCut) {

    firstLouvre = -grooveDepth / 2;
    lastLouvre = grooveSeparation * (louvreCount - 1);
    louvreTop = lastLouvre + grooveSeparation;
    
    difference() {
        // Column
        cube([columnWidth, columnWidth, columnHeight]);
        
        // Cut out diagonal grooves
        for (i = [firstLouvre : grooveSeparation : lastLouvre]) {
            groove(i, columnWidth, grooveDepth, louvreHeight); 
            translate([columnWidth - grooveDepth, columnWidth, 0])
                rotate([0, 0, -90])
                    groove(i, columnWidth, grooveDepth, louvreHeight);
        }
        
        // Cut out top groove
        translate([0, 0, louvreTop])
            cube([columnWidth, grooveDepth, louvreHeight]);
        translate([columnWidth - grooveDepth, columnWidth, louvreTop])
            rotate([0, 0, -90])
                cube([columnWidth, grooveDepth, louvreHeight]);
        
        // Cut out back
        translate([backCut, 0, cathetus(louvreDepth)])
            cube([columnWidth - backCut, columnWidth - backCut, columnHeight]);
    }
}

module louvre(columnWidth, columnHeight, grooveDepth, grooveSeparation, louvreHeight, louvreWidth, louvreDepth, louvreCount) {

    firstLouvre = -grooveDepth / 2;
    lastLouvre = grooveSeparation * (louvreCount - 1);
    
    for (i = [firstLouvre : grooveSeparation : lastLouvre]) 
        translate([0, -louvreWidth + grooveDepth, i + hypotenuse(louvreHeight)])
            rotate([0, 45, 0])
                cube([louvreHeight, louvreWidth, louvreDepth]);
}

module sill(columnWidth, grooveDepth, grooveSeparation, louvreHeight, louvreWidth, louvreCount, backCut) {
    
    translate([0, - louvreWidth + grooveDepth, grooveSeparation * louvreCount])
        difference() {
            cube([columnWidth, louvreWidth, louvreHeight]);
            translate([backCut, 0, 0])    
                rotate([0, 0, -45])
                    cube([backCut, backCut, louvreHeight]);
            translate([backCut, louvreWidth, 0])    
                rotate([0, 0, -45])
                    cube([backCut, backCut, louvreHeight]);
        }
}

module sides(s, columnWidth, louvreHeight, louvreDepth, louvreCount) {
    
    grooveDepth = round(hypotenuse(louvreHeight));
    grooveSeparation = floor(cathetus(louvreDepth)) + grooveDepth / 2;

    louvreWidth = grooveSeparation * louvreCount - (columnWidth - grooveDepth);// * 2;
    
    columnExtra = 40;
    columnHeight = grooveSeparation * louvreCount;

    columnSeparation = louvreWidth - grooveDepth * 2;
    
    backCut = cathetus(louvreHeight) + cathetus(louvreDepth);
    
    offsetX = columnSeparation / 2 + columnWidth;
    offsetY = columnSeparation / 2;
    
    for (i=[0 : s - 1]) {
        
        columnExtra = i % 3 ? 30 : 20;
        
        rotate([0, 0, i * 90])
            translate([-offsetX, offsetY, 0])  {
                column(columnWidth, columnHeight + columnExtra, grooveDepth, grooveSeparation, louvreHeight, louvreDepth, louvreCount, backCut);
                louvre(columnWidth, columnHeight, grooveDepth, grooveSeparation, louvreHeight, louvreWidth, louvreDepth, louvreCount);
                sill(columnWidth, grooveDepth, grooveSeparation, louvreHeight, louvreWidth, louvreCount, backCut);
            }
    }

    capOffset = - (offsetY + columnWidth - backCut);
    capWidth = columnSeparation + (columnWidth - backCut) * 2;

    // lower cap
    translate([capOffset, capOffset, cathetus(louvreDepth)])
        cube([capWidth, capWidth, 3]);
  
    // upper cap
    translate([capOffset, capOffset, columnHeight + louvreHeight])
        cube([capWidth, capWidth, 3]);
    
    // top cap
    topOffset = - (offsetY + columnWidth + 19);
    topWidth = columnSeparation + 2 * columnWidth + 38;
    echo(topWidth);
    translate([topOffset, topOffset, columnHeight + 30])
        rotate([-5, 0, 0])
            cube([topWidth, topWidth, louvreHeight]);
}

COLUMN_WIDTH = 28;
LOUVRE_HEIGHT = 7;
LOUVRE_DEPTH = 18;
LOUVRE_COUNT = 7;

color("white")
    sides(4, COLUMN_WIDTH, LOUVRE_HEIGHT, LOUVRE_DEPTH, LOUVRE_COUNT);