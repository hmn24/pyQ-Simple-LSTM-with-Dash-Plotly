from pyq import q 
import traceback

def define_in_q(fn):
    def wrapper(*args, **kwargs):
        try:
            return fn(*args, **kwargs)
        except Exception as err:
            traceback.print_exc()
            raise err
    setattr(q, fn.__name__, wrapper)
    return wrapper

# All pyq functions should have pyq at the start to differentiate from normal q functions
@define_in_q
def pyq_1stCheck(dummy):
    return dummy

@define_in_q
def pyq_2ndCheck(no_one, no_two):
    return no_one + no_two


