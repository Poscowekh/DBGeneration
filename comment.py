from basic_factory import *
from enum import Enum


class CommentType(Enum):
    init_comment = 0,
    init_comment_with_reply = 1,
    subcomment = 2,
    subcomment_with_reply = 3


@dataclass(frozen=True)
class Comment(RandomEntry):
    order_id: int  # already finished
    customer_id: int
    manager_id: int
    courier_id: int

    previous_comment_id: int
    order_score: int
    customer_text: str
    manager_text: str
    date: Date
    upvotes: int
    is_anonymous: bool

    possible_comment_types: ClassVar = nparray([
        CommentType.init_comment,
        CommentType.init_comment_with_reply,
        CommentType.subcomment,
        CommentType.subcomment_with_reply
    ], dtype=CommentType)

    def create(order_id: int,
               customer_id: int,
               customer_id_bounds: Tuple[int, int],
               manager_id_bounds: Tuple[int, int],
               courier_id_bounds: Tuple[int, int],
               previous_comment_id: int,
               *args, **kwargs) -> RandomEntry:
        id = Comment.latest_id
        Comment.latest_id += 1

        comment_type = choice(Comment.possible_comment_types)

        if comment_type == CommentType.init_comment or comment_type == CommentType.init_comment_with_reply:
            pass
        else:
            pass

        return Comment(
            id,
            order_id,
            rand_from_bounds(customer_id_bounds),
            rand_from_bounds(manager_id_bounds),
            rand_from_bounds(courier_id_bounds),
            previous_comment_id,
            randint(1, 11),
            "Placeholder text",
            BasicFactory.create_date(Comment.__instances__[previous_comment_id].date),
            randint(-15, +25),
            rand_bool()
        )

    def tuplefy(self) -> Tuple:
        return (self.id,
                self.order_id,
                self.customer_id,
                self.manager_id,
                self.courier_id,
                self.previous_comment_id,
                self.order_score,
                self.text) + \
               self.date.tuplefy() + \
               (self.upvotes,
                self.is_anonymous)
