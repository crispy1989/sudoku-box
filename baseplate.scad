include <sharedparams.scad>

$fa = 3;
$fs = 0.5;

basePlateWidth = slide2PosX - slide1PosX + slideWidth;
basePlateDepth = slideDepth;

basePlatePosX = slide1PosX;
basePlatePosY = slidePosY;

// Clearance on each side of the side cutouts
cutOutClearance = 0.35;

// Clearance on each side of the slide in the pin pivots
fixedPosKeyClearance = 0.2;

difference() {
    union() {
        // Main block, translated to XY reference frame of lid
        translate([basePlatePosX, basePlatePosY, 0])
            cube([basePlateWidth, basePlateDepth, basePlateThick]);
        // Pin bases
        for (holeX = [0 : holeGridSizeX - 1], holeY = [0 : holeGridSizeY - 1]) {
            translate([holeX * holeSpacing + holeGridPosX, holeY * holeSpacing + holeGridPosY, basePlateThick])
                pinBaseModule();
        }
        // Bottom slides
        bottomSlideHeight = slidePosZ - (sideSlidePosZ - postHeight) - slidePlateThick - slidePlateVerticalClearance;
        translate([slide1PosX + sideSlideWidth + cutOutClearance, slidePosY, basePlateThick])
            cube([slideWidth - sideSlideWidth - cutOutClearance, slideDepth, bottomSlideHeight]);
        translate([slide2PosX, slidePosY, basePlateThick])
            cube([slideWidth - sideSlideWidth - cutOutClearance, slideDepth, bottomSlideHeight]);
    };
    // Cut-outs
    cutOutWidth = postWidth + cutOutClearance;
    cutOutDepth = fastenerPegDepth + 2 * cutOutClearance;
    translate([basePlatePosX, slidePosY + (postDepth - fastenerPegDepth) / 2 - cutOutClearance, 0])
        cube([cutOutWidth, cutOutDepth, basePlateThick]);
    translate([basePlatePosX, slidePosY + (postDepth - fastenerPegDepth) / 2 - cutOutClearance + slideDepth / 2 - postDepth / 2, 0])
        cube([cutOutWidth, cutOutDepth, basePlateThick]);
    translate([basePlatePosX, slidePosY + (postDepth - fastenerPegDepth) / 2 - cutOutClearance + slideDepth - postDepth, 0])
        cube([cutOutWidth, cutOutDepth, basePlateThick]);
    translate([basePlatePosX + basePlateWidth - cutOutWidth, slidePosY + (postDepth - fastenerPegDepth) / 2 - cutOutClearance, 0])
        cube([cutOutWidth, cutOutDepth, basePlateThick]);
    translate([basePlatePosX + basePlateWidth - cutOutWidth, slidePosY + (postDepth - fastenerPegDepth) / 2 - cutOutClearance + slideDepth / 2 - postDepth / 2, 0])
        cube([cutOutWidth, cutOutDepth, basePlateThick]);
    translate([basePlatePosX + basePlateWidth - cutOutWidth, slidePosY + (postDepth - fastenerPegDepth) / 2 - cutOutClearance + slideDepth - postDepth, 0])
        cube([cutOutWidth, cutOutDepth, basePlateThick]);
    // Clip ball indents
    clipBallX = basePlatePosX + basePlateWidth / 2;
    for (i = [0 : 2])
        for (x = [clipBallX - clipBallSpacing, clipBallX, clipBallX + clipBallSpacing])
        translate([
            x,
            slidePosY + postDepth / 2 + i * (-postDepth / 2 + slideDepth / 2),
            0
        ])
            sphere(r=clipBallRadius);
}

module pinBaseModule() {
    // Pivot peg
    pinBottomCavityHeightClearance = 2;
    cylinder(h=pinBottomCavityHeight - pinBottomCavityHeightClearance, r=pinBottomCavityRadius - pinBottomCavityClearance);
    // Surround
    pinSurroundClearance = pinBottomCavityClearance;
    pinSurroundThickness = 1.5;
    surroundInnerRadius = pinBottomRadius + pinSurroundClearance;
    surroundOuterRadius = surroundInnerRadius + pinSurroundThickness;
    surroundHeight = fixedPinFinHeight;
    topGapAngle = 0;
    difference() {
        // Partial cylinder with top cut out
        rotate([0, 0, 90 + topGapAngle / 2])
            rotate_extrude(angle=360 - topGapAngle)
                translate([surroundInnerRadius, 0])
                    square([pinSurroundThickness, surroundHeight]);
        // Slots for fixed pins
        rotate([0, 0, 45])
            translate([-fixedPinSlotWidth/2, -surroundOuterRadius, 0])
                cube([fixedPinSlotWidth, surroundOuterRadius * 2, surroundHeight]);
        rotate([0, 0, -45])
            translate([-fixedPinSlotWidth/2, -surroundOuterRadius, 0])
                cube([fixedPinSlotWidth, surroundOuterRadius * 2, surroundHeight]);
    };
    // Detent prong post
    detentPostHeight = basePlateDetentProngOffsetZ + detentProngHeight / 2;
    detentPostPosY = pinBottomRadius + detentProngLength;
    translate([0, detentPostPosY + detentPostDepth/2, detentPostHeight / 2])
        cube([detentPostWidth, detentPostDepth, detentPostHeight], center = true);
    // Chamfer at bottom of post
    chamferSize = 1.2;
    translate([detentPostWidth / 2, detentPostPosY, 0])
    rotate([90, 0, -90])
    linear_extrude(detentPostWidth)
    polygon([[0, 0], [chamferSize, 0], [0, chamferSize]]);
    // Detent prong
    // construct the detent prong as follows:
    // - create a polygon XY cross section of the prong, including point geometry and chamfers at base (centered along X axis, negative half of the Y axis)
    // - extrude it along the Z axis
    // - subtract a 45 degree triangle from the bottom to taper it and make it easier to print
    prongThick = 0.8; // thickness of prong
    sideChamferSize = detentProngLength / 8;
    detentProngTotalHeight = detentProngLength + detentProngHeight;
    prongPointDepth = 0.6; // length of point of prong that protrudes into pin detent
    prongPointWidth = prongThick / 3;
    prongTotalLength = detentProngLength + prongPointDepth;
    translate([0, detentPostPosY, detentPostHeight - detentProngTotalHeight])
        difference() {
            linear_extrude(detentProngTotalHeight)
                polygon([
                    [-prongThick/2 - sideChamferSize, 0],
                    [prongThick/2 + sideChamferSize, 0],
                    [prongThick/2, -sideChamferSize],
                    [prongThick/2, -detentProngLength],
                    [prongPointWidth/2, -detentProngLength - prongPointDepth],
                    [-prongPointWidth/2, -detentProngLength - prongPointDepth],
                    [-prongThick/2, -detentProngLength],
                    [-prongThick/2, -sideChamferSize],
                ]);
            translate([prongThick/2 + sideChamferSize, -prongTotalLength, 0])
                rotate([0, -90, 0])
                    linear_extrude(prongThick + 2*sideChamferSize)
                        polygon([
                            [0, 0],
                            [0, prongTotalLength],
                            [prongTotalLength, 0]
                        ]);
        };
    
    
/*
    prongPointDepth = 0.4; // length of point of prong that protrudes into pin detent
    prongThick = 0.8; // thickness of prong
    prongBottomOffset = detentPostHeight - detentProngHeight - detentProngLength - prongPointDepth; // distance from base plate to base of prong arm
    translate([prongThick / 2, detentPostPosY, prongBottomOffset])
        rotate([90, 0, -90])
            linear_extrude(prongThick)
                polygon([
                    [0, 0],
                    [0, detentPostHeight - prongBottomOffset],
                    [detentProngLength + prongPointDepth, detentPostHeight - prongBottomOffset],
                    [detentProngLength + prongPointDepth, detentPostHeight - prongBottomOffset - detentProngHeight]
                ]);
    // Prong side chamfers
    sideChamferSize = detentProngLength / 8;
    translate([prongThick / 2, detentPostPosY, prongBottomOffset + sideChamferSize])
        linear_extrude(detentPostHeight - prongBottomOffset - sideChamferSize)
            polygon([[0, 0], [0, -sideChamferSize], [sideChamferSize, 0]]);
    mirror([1, 0, 0])
        translate([prongThick / 2, detentPostPosY, prongBottomOffset + sideChamferSize])
            linear_extrude(detentPostHeight - prongBottomOffset - sideChamferSize)
                polygon([[0, 0], [0, -sideChamferSize], [sideChamferSize, 0]]);
*/
};
