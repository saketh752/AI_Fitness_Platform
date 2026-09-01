import math
from typing import Sequence


Point2D = tuple[float, float]
Point3D = tuple[float, float, float]


def calculate_angle_2d(
    point_a: Point2D,
    point_b: Point2D,
    point_c: Point2D,
) -> float:
    """
    Calculate the angle ABC in degrees.

    The angle is measured at point B.

    Returns a value between 0 and 180 degrees.
    """

    ba_x = point_a[0] - point_b[0]
    ba_y = point_a[1] - point_b[1]

    bc_x = point_c[0] - point_b[0]
    bc_y = point_c[1] - point_b[1]

    magnitude_ba = math.hypot(ba_x, ba_y)
    magnitude_bc = math.hypot(bc_x, bc_y)

    if magnitude_ba == 0 or magnitude_bc == 0:
        raise ValueError(
            "Cannot calculate angle when two points overlap."
        )

    dot_product = (
        ba_x * bc_x
        + ba_y * bc_y
    )

    cosine = (
        dot_product
        / (magnitude_ba * magnitude_bc)
    )

    # Floating-point calculations can occasionally
    # produce values slightly outside [-1, 1].
    cosine = max(-1.0, min(1.0, cosine))

    angle = math.degrees(
        math.acos(cosine)
    )

    return angle


def calculate_angle_3d(
    point_a: Point3D,
    point_b: Point3D,
    point_c: Point3D,
) -> float:
    """
    Calculate the 3D angle ABC in degrees.

    The angle is measured at point B.

    Returns a value between 0 and 180 degrees.
    """

    ba = (
        point_a[0] - point_b[0],
        point_a[1] - point_b[1],
        point_a[2] - point_b[2],
    )

    bc = (
        point_c[0] - point_b[0],
        point_c[1] - point_b[1],
        point_c[2] - point_b[2],
    )

    magnitude_ba = math.sqrt(
        sum(value * value for value in ba)
    )

    magnitude_bc = math.sqrt(
        sum(value * value for value in bc)
    )

    if magnitude_ba == 0 or magnitude_bc == 0:
        raise ValueError(
            "Cannot calculate angle when two points overlap."
        )

    dot_product = sum(
        ba[index] * bc[index]
        for index in range(3)
    )

    cosine = (
        dot_product
        / (magnitude_ba * magnitude_bc)
    )

    cosine = max(-1.0, min(1.0, cosine))

    angle = math.degrees(
        math.acos(cosine)
    )

    return angle


def calculate_distance_2d(
    point_a: Point2D,
    point_b: Point2D,
) -> float:
    """Calculate Euclidean distance between two 2D points."""

    return math.hypot(
        point_a[0] - point_b[0],
        point_a[1] - point_b[1],
    )


def calculate_distance_3d(
    point_a: Point3D,
    point_b: Point3D,
) -> float:
    """Calculate Euclidean distance between two 3D points."""

    return math.sqrt(
        (point_a[0] - point_b[0]) ** 2
        + (point_a[1] - point_b[1]) ** 2
        + (point_a[2] - point_b[2]) ** 2
    )


def calculate_midpoint_2d(
    point_a: Point2D,
    point_b: Point2D,
) -> Point2D:
    """Calculate midpoint between two 2D points."""

    return (
        (point_a[0] + point_b[0]) / 2,
        (point_a[1] + point_b[1]) / 2,
    )


def calculate_midpoint_3d(
    point_a: Point3D,
    point_b: Point3D,
) -> Point3D:
    """Calculate midpoint between two 3D points."""

    return (
        (point_a[0] + point_b[0]) / 2,
        (point_a[1] + point_b[1]) / 2,
        (point_a[2] + point_b[2]) / 2,
    )