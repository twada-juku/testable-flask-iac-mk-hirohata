from wtforms.validators import ValidationError

def unique_attr(model, attr, session):
    def _uniqueness(form, field):
        criteria = dict([[attr, field.data]])
        found = session.query(model).filter_by(**criteria).first()
        if found:
            raise ValidationError(field.label.text + 'の値が既に使われています')
    return _uniqueness
