import random
from robot.api.deco import keyword
from robot.api import logger


class ExampleLibrary:

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    @staticmethod
    @keyword('Get random item from ${list}')
    def get_random_list_item(alist: list):
        item = alist[random.randrange(0, len(alist) - 1)]
        logger.info(item)
        return item
