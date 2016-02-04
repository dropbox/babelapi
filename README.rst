*****
Babel
*****

**This repository is a stub. No code is available yet. Check back soon.**

Define an API once in Babel. Use code generators to translate your
specification into objects and functions in the programming languages of your
choice.

Babel is made up of several components:

    1. An interface-description language (IDL) for specifying APIs.
    2. A command-line tool (``babelapi``) that takes an API specification and
       generator module, and generates output.
    3. A Python-interface for defining new generators.
    4. A JSON-compatible serialization format.

Babel is in active use for the `Dropbox v2 API
<http://www.dropbox.com/developers>`_. Right now, the only available generator
is for Python, but we're working on releasing the other ones we have
internally: Swift, C#, Java, Go, JavaScript, and HTML documentation.

    * Introduction
        * Motivation_
        * Installation_
        * `Taste of Babel <#a-taste-of-babel>`_
    * `Language Reference (.babel) <doc/lang_ref.rst>`_
        * `Choosing a Filename <doc/lang_ref.rst#choosing-a-filename>`_
        * `Comments <doc/lang_ref.rst#comments>`_
        * `Namespace <doc/lang_ref.rst#ns>`_
        * `Primitive Types <doc/lang_ref.rst#primitive-types>`_
        * `Alias <doc/lang_ref.rst#alias>`_
        * `Struct <doc/lang_ref.rst#struct>`_
        * `Union <doc/lang_ref.rst#union>`_
        * `Nullable Type <doc/lang_ref.rst#nullable-type>`_
        * `Route <doc/lang_ref.rst#route>`_
        * `Include <doc/lang_ref.rst#include>`_
        * `Documentation <doc/lang_ref.rst#doc>`_
        * `Formal Grammar <doc/lang_ref.rst#formal-grammar>`_
    * `Using Generated Code <doc/using_generator.rst>`_
        * `Compile with the CLI <doc/using_generator.rst#compile-with-the-cli>`_
        * `Python Guide <doc/using_generator.rst#python-guide>`_
    * `Managing Specs <doc/managing_specs.rst>`_
        * `Using Namespaces <doc/managing_specs.rst#using-namespaces>`_
        * `Splitting a Namespace Across Files <doc/managing_specs.rst#splitting-a-namespace-across-files>`_
        * `Using Header Files <doc/managing_specs.rst#using-header-files>`_
        * `Separating Public and Private Routes <doc/managing_specs.rst#separation-public-and-private-routes>`_
    * `Evolving a Spec <doc/evolve_spec.rst>`_
        * `Background <doc/evolve_spec.rst#background>`_
        * `Sender-Recipient <doc/evolve_spec.rst#sender-recipient>`_
        * `Backwards Incompatible Changes <doc/evolve_spec.rst#backwards-incompatible-changes>`_
        * `Backwards Compatible Changes <doc/evolve_spec.rst#backwards-compatible-changes>`_
        * `Planning for Backwards Compatibility <doc/evolve_spec.rst#planning-for-backwards-compatibility>`_
        * `Leader-Clients <doc/evolve_spec.rst#leader-clients>`_
        * `Route Versioning <doc/evolve_spec.rst#route-versioning>`_
    * `Writing a Generator (.babelg.py) <doc/generator_ref.rst>`_
        * `Using the API Object <doc/generator_ref.rst#using-the-api-object>`_
        * `Creating an Output File <doc/generator_ref.rst#creating-an-output-file>`_
        * `Emit Methods <doc/generator_ref.rst#emit-methods>`_
        * `Indentation <doc/generator_ref.rst#indentation>`_
        * `Examples <doc/generator_ref.rst#examples>`_
    * `JSON Serializer <doc/json_serializer.rst>`_
    * `Network Protocol <doc/network_protocol.rst>`_

.. _motivation:

Motivation
==========

Babel was birthed at Dropbox at a time when it was becoming clear that API
development needed to be scaled beyond a single team. The company was
undergoing a large expansion in the number of product groups, and it wasn't
scalable for the API team, which traditionally dealt with core file operations,
to learn the intricacies of each product and build their APIs.

Babel's chief goal is to decentralize API development and ownership at Dropbox.
To be successful, it needed to do several things:

**Decouple APIs from SDKS**: Dropbox has first-party clients for our mobile
apps, desktop client, and website. Each of these is implemented in a different
language. And we want to make onboarding easier for third-parties by providing
them with SDKs. It's untenable to ask product groups that build APIs to also
implement these endpoints in a half-dozen different language-specific SDKs.
Without decoupling, as was the case in our v1 API, the SDKs will inevitably
fall behind. Our solution is to have our SDKs automatically generated.

**Improve Visibility into our APIs**: These days, APIs aren't just in the
domain of engineering. Product managers, product specialists, partnerships,
sales, and services groups all need to have clear and accurate specifications
of our APIs. After all, APIs define Dropbox's data models and functionlaity.
Before Babel, API design documents obseleted by changes during implementation
were the source of truth.

**Consistency and Predictability**: Consistency ranging from documentation
tense to API patterns are important for making an API predictable and therefore
easier to use. We needed an easy way to make and enforce patterns.

**JSON**: To make consumption easier for third parties, we wanted our data
types to map to JSON. For cases where serialization efficiency
(space and time) are important, you can try using msgpack (alpha support
available in the Python generator). It's possible also to define your own
serialization scheme, but at that point, you may consider using something like
`Protobuf <https://github.com/google/protobuf>`_.

Assumptions
-----------

Babel makes no assumptions about the transport layer being used to make API
requests and return responses; its first use case is the Dropbox v2 API which
operates over HTTP. Babel does not come with nor enforce any particular RPC
framework.

Babel makes some assumptions about the data types supported in target
programming languages. It's assumed that there is a capacity for representing
dictionaries (unordered string keys -> value), lists, numeric types, and
strings.


Babel assumes that a route (or API endpoint) can have its argument and
result types defined without relation to each other. In other words, the
type of response does not change based on the input to the endpoint. An
exception to this rule is afforded for error responses.

.. _installation:

Installation
============

Download or clone BabelAPI, and run the following in its root directory::

    $ sudo python setup.py install

This will install a script ``babelapi`` to your PATH that can be run from the
command line::

    $ babelapi -h

Alternative
-----------

If you choose not to install ``babelapi`` using the method above, you will need
to ensure that you have the Python packages ``ply`` and ``six``, which can be
installed through ``pip``::

    $ pip install ply>=3.4 six>=1.3.0

If the ``babelapi`` package is in your PYTHONPATH, you can replace ``babelapi``
with ``python -m babelapi.cli`` as follows::

    $ python -m babelapi.cli -h

If you have the ``babelapi`` package on your machine, but did not install it or
add its location to your PYTHONPATH, you can use the following::

    $ PYTOHNPATH=path/to/babelapi python -m babelapi.cli -h

.. taste-of-babel:

A Taste of Babel
================

Here we define a hypothetical route that shows up in some form or another in
APIs for web services: querying the account information for a user of a
service. Our hypothetical spec lives in a file called ``users.babel``::

    # We put this in the "users" namespace in anticipation that
    # there would be many user-account-related routes.
    namespace users

    route get_account (GetAccountReq, Account, GetAccountErr)
        "Get information about a specified user's account."

    # This struct represents the input data to the route.
    struct GetAccountReq
        account_id AccountId

    # We define an AccountId as being a 10-character string
    # once here to avoid declaring it each time.
    alias AccountId = String(min_length=10, max_length=10)

    struct Account
        "Information about a user's account."

        account_id AccountId
            "A unique identifier for the user's account."
        email String(pattern="^[^@]+@[^@]+\.[^@]+$")
            "The e-mail address of the user."
        name String(min_length=1)?
            "The user's full name. :val:`null` if no name was provided."
        status Status
            "The status of the account."

        example default "A regular user"
            account_id="id-48sa2f0"
            email="alex@example.org"
            name="Alexander the Great"
            status=active

    union Status
        active
            "The account is active."
        inactive Timestamp("%a, %d %b %Y %H:%M:%S")
            "The account is inactive. The value is when the account was
            deactivated."

    # This union represents the possible errors that might be returned.
    union GetAccountErr
        no_account
            "No account with the requested id could be found."
        perm_denied
            "Insufficient privileges to query account information."
        unknown*

Using the Python generator, we can generate a Python module that mirrors this
specification using the command-line interface. From the top-level of the
``babelapi`` folder, try::

    $ babelapi generator/python/python.babelg.py . users.babel

Now we can interact with the specification in Python::

    $ python -i users.py
    >>> a = Account()
    >>> a.account_id = 1234 # fails type validation
    Traceback (most recent call last):
      ...
    babel_data_types.ValidationError: '1234' expected to be a string, got integer

    >>> a.account_id = '1234' # fails length validation
    Traceback (most recent call last):
      ...
    babel_data_types.ValidationError: '1234' must be at least 10 characters, got 4

    >>> a.account_id = 'id-48sa2f0' # passes validation

    >>> # Now we use the included JSON serializer
    >>> from babel_serializers import json_encode
    >>> a2 = Account(account_id='id-48sa2f0', name='Alexander the Great',
    ...              email='alex@example.org', status=Status.active)
    >>> json_encode(GetAccountRoute.result_data_type, a2)
    '{"status": "active", "account_id": "id-48sa2f0", "name": "Alexander the Great", "email": "alex@example.org"}'
