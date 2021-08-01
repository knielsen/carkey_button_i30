l1 = 15.7-1.0;
l2 = 16.2-1.0;
w = 8.0;
d = 5.0;
pin_dia = 4.0;
pin_dia2 = 2.4;

d1 = 0.4;   // Thickness of cover_inside, the pressable flexible cover
d2 = 0.8;   // Thickness of cover above edge of button hole
d3 = 2.6;   // Total height from button of hole (including d1)

thick = 0.8;
toll_r = 0.35;
corner_r = 1.5;

cutout_r = 10;
cutout_h = 10;
cutout_d = d2 + 0.2;
slit_w = 0.25;
icon_w = 4.5;

with_icon=true;
use_measured_base = false;

$fa = 5;
$fs = 0.1;

points_base = [ [-.5*l1, -.5*w], [-.5*l2, .5*w], [.5*l2, .5*w], [.5*l1, -.5*w]];

function prev(i, L) = (i<=0 ? len(L)-1 : i-1);
function next(i, L) = (i>=len(L)-1 ? 0 : i+1);

module base2d_coords() {
  deltas = [[-1,-1], [-1, 1], [1, 1], [1, -1]];
  hull() {
    for (i = [0 : 1]) {
      for (j = [0 : 1]) {
        x = points_base[i*2+j][0];
        y = points_base[i*2+j][1];
        dx = deltas[i*2+j][0];
        dy = deltas[i*2+j][1];
        translate([x - dx*corner_r, y - dy*corner_r]) {
          circle(r=corner_r);
        }
      }
    }
  }
}

module base2d_measured() {
  scale([1.059, 1.059*(7.3+0.2)/7.3]) {
    import("carkey_button_outlines.svg", center=true);
  }
}

module base2d() {
  if (use_measured_base) {
    base2d_measured();
  } else {
    base2d_coords();
  }
}

module lock_icon() {
  translate([1.0, 0]) {
    translate([-3.2,0]) {
      difference() {
        circle(r=.5*icon_w-0.2);
        circle(r=.5*icon_w-0.6);
        translate([.5*icon_w-0.6, 0]) {
          square(size=[2, 10], center=true);
        }
      }
    }
    difference() {
      offset(r=0.6) {
        square(size=[5.2-2*0.6, icon_w-2*0.6], center=true);
      }
      offset(r=0.4) {
        square(size=[5.2-2*0.6-0.4, icon_w-2*0.6-0.4], center=true);
      }
      translate([-2,0]) {
        square(size=[2.0, icon_w], center=true);
      }
    }
    difference() {
      square(size=[5.2, icon_w], center=true);
      square(size=[5.2-2*0.4, icon_w-2*0.4], center=true);
      translate([2.2,0]) {
        square(size=[2.0, icon_w], center=true);
      }
    }
    translate([-0.5,0]) {
      circle(r=0.6);
      translate([0.8, 0])
        square(size=([1.6,0.4]), center=true);
    }
  }
}

module cover_outside() {
  linear_extrude(height=d2, convexity=10) {
    difference() {
      base2d();
      offset(r = -thick) {
        base2d();
      }
    }
  }
}

module cover_inside() {
  linear_extrude(height=d1, convexity=10) {
    difference() {
      base2d();
      for (i = [-1 : 2 : 1]) {
        translate([0, i*(.5*w-thick-toll_r-.5*slit_w)]) {
          square(size=[(i<0?l1:l2),slit_w], center=true);
        }
      }
    }
  }
}

module cover_icon() {
  translate([0, 0, -1]) {
    linear_extrude(height=0.2+1, convexity=10) {
      lock_icon();
    }
  }
}

module insert_full() {
  linear_extrude(height=d3, convexity=10) {
    difference() {
      offset(r = -toll_r) {
        base2d();
      }
      offset(r = -(toll_r+thick)) {
        base2d();
      }
    }
  }
}

module insert_cutout() {
  translate([0, 0, cutout_r + cutout_d]) {
    rotate([90, 0, 0]) {
      cylinder(r=cutout_r, h=cutout_h, center=true);
    }
  }
}

module button_pin() {
  translate([0, 0, 0.2+1e-3]) {
    linear_extrude(height=d-0.2, scale=pin_dia2/pin_dia, convexity=10) {
      circle(r=.5*pin_dia - toll_r);
    }
  }
}

module button_v1() {
  difference() {
    cover_inside();
    if (with_icon) {
      cover_icon();
    }
  }

  cover_outside();

  difference() {
    insert_full();
    insert_cutout();
  }

  button_pin();
}

button_v1();
//insert_full();
